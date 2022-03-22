# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'
require 'database_cleaner'
require 'sidekiq/testing'

DatabaseCleaner.strategy = :truncation, { except: ['event_types'] }

describe LicenseCheckoutService do
  let(:account) { create(:account) }
  let(:license) { create(:license, account: account) }

  # See: https://github.com/mhenrixon/sidekiq-unique-jobs#testing
  before do
    Sidekiq::Testing.fake!
  end

  after do
    DatabaseCleaner.clean
  end

  it 'should return a license file certificate' do
    cert = LicenseCheckoutService.call(
      account: account,
      license: license,
    )

    expect(cert).to start_with "-----BEGIN LICENSE FILE-----\n"
    expect(cert).to end_with "-----END LICENSE FILE-----\n"
  end

  it 'should return an encoded JSON payload' do
    cert = LicenseCheckoutService.call(
      account: account,
      license: license,
    )

    dec = nil
    enc = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
              .delete_suffix("-----END LICENSE FILE-----\n")

    expect { dec = Base64.decode64(enc) }.to_not raise_error
    expect(dec).to_not be_nil

    json = nil

    expect { json = JSON.parse(dec) }.to_not raise_error
    expect(json).to_not be_nil
    expect(json).to include(
      'enc' => a_kind_of(String),
      'sig' => a_kind_of(String),
      'alg' => a_kind_of(String),
    )
  end

  it 'should return an encoded license' do
    cert = LicenseCheckoutService.call(
      account: account,
      license: license,
    )

    payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                  .delete_suffix("-----END LICENSE FILE-----\n")

    json = JSON.parse(Base64.decode64(payload))
    enc  = json.fetch('enc')
    data = nil

    expect { data = JSON.parse(Base64.strict_decode64(enc)) }.to_not raise_error

    expect(data).to_not be_nil
    expect(data).to include(
      'meta' => include(
        'iat' => a_kind_of(String),
        'exp' => a_kind_of(String),
        'ttl' => a_kind_of(Integer),
      ),
      'data' => include(
        'type' => 'licenses',
        'id' => license.id,
      ),
    )
  end

  context 'when invalid parameters are supplied to the service' do
    it 'should raise an error when account is nil' do
      checkout = -> {
        LicenseCheckoutService.call(
          account: nil,
          license: license,
        )
      }

      expect { checkout.call }.to raise_error LicenseCheckoutService::InvalidAccountError
    end

    it 'should raise an error when license is nil' do
      checkout = -> {
        LicenseCheckoutService.call(
          account: account,
          license: nil,
        )
      }

      expect { checkout.call }.to raise_error LicenseCheckoutService::InvalidLicenseError
    end

    it 'should raise an error when includes are invalid' do
      checkout = -> {
        LicenseCheckoutService.call(
          account: account,
          license: license,
          include: %w[
            account
          ]
        )
      }

      expect { checkout.call }.to raise_error LicenseCheckoutService::InvalidIncludeError
    end

    it 'should raise an error when TTL is too short' do
      checkout = -> {
        LicenseCheckoutService.call(
          account: account,
          license: license,
          ttl: 1.minute,
        )
      }

      expect { checkout.call }.to raise_error LicenseCheckoutService::InvalidTTLError
    end
  end

  %w[
    ED25519_SIGN
  ].each do |scheme|
    context "when the signing scheme is #{scheme}" do
      let(:policy) { create(:policy, scheme.downcase.to_sym, account: account) }
      let(:license) { create(:license, policy: policy, account: account) }

      context 'when the license file is not encrypted' do
        it 'should have a correct algorithm' do
          cert = LicenseCheckoutService.call(
            account: account,
            license: license,
          )

          payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                        .delete_suffix("-----END LICENSE FILE-----\n")

          dec  = Base64.decode64(payload)
          json = JSON.parse(dec)

          expect(json).to include(
            'alg' => 'base64+ed25519'
          )
        end

        it 'should sign the encoded payload' do
          cert = LicenseCheckoutService.call(
            account: account,
            license: license,
          )

          payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                        .delete_suffix("-----END LICENSE FILE-----\n")

          dec  = Base64.decode64(payload)
          json = JSON.parse(dec)

          enc       = json.fetch('enc')
          sig       = json.fetch('sig')
          sig_bytes = Base64.strict_decode64(sig)

          verify_key = Ed25519::VerifyKey.new([account.ed25519_public_key].pack('H*'))
          verify     = -> {
            verify_key.verify(sig_bytes, "license/#{enc}")
          }

          expect { verify.call }.to_not raise_error
          expect(verify.call).to be true
        end
      end

      context 'when the license file is encrypted' do
        it 'should have a correct algorithm' do
          cert = LicenseCheckoutService.call(
            account: account,
            license: license,
            encrypt: true,
          )

          payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                        .delete_suffix("-----END LICENSE FILE-----\n")

          dec  = Base64.decode64(payload)
          json = JSON.parse(dec)

          expect(json).to include(
            'alg' => 'aes-256-cbc+ed25519'
          )
        end

        it 'should sign the encrypted payload' do
          cert = LicenseCheckoutService.call(
            account: account,
            license: license,
            encrypt: true,
          )

          payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                        .delete_suffix("-----END LICENSE FILE-----\n")

          dec  = Base64.decode64(payload)
          json = JSON.parse(dec)

          enc       = json.fetch('enc')
          sig       = json.fetch('sig')
          sig_bytes = Base64.strict_decode64(sig)

          verify_key = Ed25519::VerifyKey.new([account.ed25519_public_key].pack('H*'))
          verify     = -> {
            verify_key.verify(sig_bytes, "license/#{enc}")
          }

          expect { verify.call }.to_not raise_error
          expect(verify.call).to be true
        end
      end
    end
  end

  %w[
    RSA_2048_PKCS1_PSS_SIGN_V2
    RSA_2048_PKCS1_PSS_SIGN
  ].each do |scheme|
    context "when the signing scheme is #{scheme}" do
      let(:policy) { create(:policy, scheme.downcase.to_sym, account: account) }
      let(:license) { create(:license, policy: policy, account: account) }

      context 'when the license file is not encrypted' do
        it 'should have a correct algorithm' do
          cert = LicenseCheckoutService.call(
            account: account,
            license: license,
          )

          payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                        .delete_suffix("-----END LICENSE FILE-----\n")

          dec  = Base64.decode64(payload)
          json = JSON.parse(dec)

          expect(json).to include(
            'alg' => 'base64+rsa-pss-sha256'
          )
        end

        it 'should sign the encoded payload' do
          cert = LicenseCheckoutService.call(
            account: account,
            license: license,
          )

          payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                        .delete_suffix("-----END LICENSE FILE-----\n")

          dec  = Base64.decode64(payload)
          json = JSON.parse(dec)

          enc       = json.fetch('enc')
          sig       = json.fetch('sig')
          sig_bytes = Base64.strict_decode64(sig)

          pub_key = OpenSSL::PKey::RSA.new(account.public_key)
          digest  = OpenSSL::Digest::SHA256.new
          verify  = -> {
            pub_key.verify_pss(digest, sig_bytes, "license/#{enc}", salt_length: :auto, mgf1_hash: 'SHA256')
          }

          expect { verify.call }.to_not raise_error
          expect(verify.call).to be true
        end
      end

      context 'when the license file is encrypted' do
        it 'should have a correct algorithm' do
          cert = LicenseCheckoutService.call(
            account: account,
            license: license,
            encrypt: true,
          )

          payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                        .delete_suffix("-----END LICENSE FILE-----\n")

          dec  = Base64.decode64(payload)
          json = JSON.parse(dec)

          expect(json).to include(
            'alg' => 'aes-256-cbc+rsa-pss-sha256'
          )
        end

        it 'should sign the encrypted payload' do
          cert = LicenseCheckoutService.call(
            account: account,
            license: license,
            encrypt: true,
          )

          payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                        .delete_suffix("-----END LICENSE FILE-----\n")

          dec  = Base64.decode64(payload)
          json = JSON.parse(dec)

          enc       = json.fetch('enc')
          sig       = json.fetch('sig')
          sig_bytes = Base64.strict_decode64(sig)

          pub_key = OpenSSL::PKey::RSA.new(account.public_key)
          digest  = OpenSSL::Digest::SHA256.new
          verify  = -> {
            pub_key.verify_pss(digest, sig_bytes, "license/#{enc}", salt_length: :auto, mgf1_hash: 'SHA256')
          }

          expect { verify.call }.to_not raise_error
          expect(verify.call).to be true
        end
      end
    end
  end

  %w[
    RSA_2048_PKCS1_SIGN_V2
    RSA_2048_PKCS1_SIGN
    RSA_2048_PKCS1_ENCRYPT
    RSA_2048_JWT_RS256
  ].each do |scheme|
    context "when the signing scheme is #{scheme}" do
      let(:policy) { create(:policy, scheme.downcase.to_sym, account: account) }
      let(:license) { create(:license, policy: policy, account: account) }

      context 'when the license file is not encrypted' do
        it 'should have a correct algorithm' do
          cert = LicenseCheckoutService.call(
            account: account,
            license: license,
          )

          payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                        .delete_suffix("-----END LICENSE FILE-----\n")

          dec  = Base64.decode64(payload)
          json = JSON.parse(dec)

          expect(json).to include(
            'alg' => 'base64+rsa-sha256'
          )
        end

        it 'should sign the encoded payload' do
          cert = LicenseCheckoutService.call(
            account: account,
            license: license,
          )

          payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                        .delete_suffix("-----END LICENSE FILE-----\n")

          dec  = Base64.decode64(payload)
          json = JSON.parse(dec)

          enc       = json.fetch('enc')
          sig       = json.fetch('sig')
          sig_bytes = Base64.strict_decode64(sig)

          pub_key = OpenSSL::PKey::RSA.new(account.public_key)
          digest  = OpenSSL::Digest::SHA256.new
          verify  = -> {
            pub_key.verify(digest, sig_bytes, "license/#{enc}")
          }

          expect { verify.call }.to_not raise_error
          expect(verify.call).to be true
        end
      end

      context 'when the license file is encrypted' do
        it 'should have a correct algorithm' do
          cert = LicenseCheckoutService.call(
            account: account,
            license: license,
            encrypt: true,
          )

          payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                        .delete_suffix("-----END LICENSE FILE-----\n")

          dec  = Base64.decode64(payload)
          json = JSON.parse(dec)

          expect(json).to include(
            'alg' => 'aes-256-cbc+rsa-sha256'
          )
        end

        it 'should sign the encrypted payload' do
          cert = LicenseCheckoutService.call(
            account: account,
            license: license,
            encrypt: true,
          )

          payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                        .delete_suffix("-----END LICENSE FILE-----\n")

          dec  = Base64.decode64(payload)
          json = JSON.parse(dec)

          enc       = json.fetch('enc')
          sig       = json.fetch('sig')
          sig_bytes = Base64.strict_decode64(sig)

          pub_key = OpenSSL::PKey::RSA.new(account.public_key)
          digest  = OpenSSL::Digest::SHA256.new
          verify  = -> {
            pub_key.verify(digest, sig_bytes, "license/#{enc}")
          }

          expect { verify.call }.to_not raise_error
          expect(verify.call).to be true
        end
      end
    end
  end

  context 'when the signing scheme is nil' do
    let(:license) { create(:license, account: account) }

    context 'when the license file is not encrypted' do
      it 'should have a correct algorithm' do
        cert = LicenseCheckoutService.call(
          account: account,
          license: license,
        )

        payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                      .delete_suffix("-----END LICENSE FILE-----\n")

        dec  = Base64.decode64(payload)
        json = JSON.parse(dec)

        expect(json).to include(
          'alg' => 'base64+ed25519'
        )
      end

      it 'should sign the encoded payload' do
        cert = LicenseCheckoutService.call(
          account: account,
          license: license,
        )

        payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                      .delete_suffix("-----END LICENSE FILE-----\n")

        dec  = Base64.decode64(payload)
        json = JSON.parse(dec)

        enc       = json.fetch('enc')
        sig       = json.fetch('sig')
        sig_bytes = Base64.strict_decode64(sig)

        verify_key = Ed25519::VerifyKey.new([account.ed25519_public_key].pack('H*'))
        verify     = -> {
          verify_key.verify(sig_bytes, "license/#{enc}")
        }

        expect { verify.call }.to_not raise_error
        expect(verify.call).to be true
      end
    end

    context 'when the license file is encrypted' do
      it 'should have a correct algorithm' do
        cert = LicenseCheckoutService.call(
          account: account,
          license: license,
          encrypt: true,
        )

        payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                      .delete_suffix("-----END LICENSE FILE-----\n")

        dec  = Base64.decode64(payload)
        json = JSON.parse(dec)

        expect(json).to include(
          'alg' => 'aes-256-cbc+ed25519'
        )
      end

      it 'should sign the encrypted payload' do
        cert = LicenseCheckoutService.call(
          account: account,
          license: license,
          encrypt: true,
        )

        payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                      .delete_suffix("-----END LICENSE FILE-----\n")

        dec  = Base64.decode64(payload)
        json = JSON.parse(dec)

        enc       = json.fetch('enc')
        sig       = json.fetch('sig')
        sig_bytes = Base64.strict_decode64(sig)

        verify_key = Ed25519::VerifyKey.new([account.ed25519_public_key].pack('H*'))
        verify     = -> {
          verify_key.verify(sig_bytes, "license/#{enc}")
        }

        expect { verify.call }.to_not raise_error
        expect(verify.call).to be true
      end
    end
  end

  context 'when using encryption' do
    it 'should return an encoded JSON payload' do
      cert = LicenseCheckoutService.call(
        account: account,
        license: license,
      )

      dec = nil
      enc = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                .delete_suffix("-----END LICENSE FILE-----\n")

      expect { dec = Base64.decode64(enc) }.to_not raise_error
      expect(dec).to_not be_nil

      json = nil

      expect { json = JSON.parse(dec) }.to_not raise_error
      expect(json).to_not be_nil
      expect(json).to include(
        'enc' => a_kind_of(String),
        'sig' => a_kind_of(String),
        'alg' => a_kind_of(String),
      )
    end

    it 'should return an encrypted license' do
      cert = LicenseCheckoutService.call(
        account: account,
        license: license,
        encrypt: true,
      )

      payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                    .delete_suffix("-----END LICENSE FILE-----\n")

      json    = JSON.parse(Base64.decode64(payload))
      enc     = json.fetch('enc')
      decrypt = -> {
        aes = OpenSSL::Cipher::AES256.new(:CBC)
        aes.decrypt

        key            = OpenSSL::Digest::SHA256.digest(license.key)
        ciphertext, iv = enc.split('.')
                            .map { Base64.strict_decode64(_1) }

        aes.key = key
        aes.iv  = iv

        plaintext = aes.update(ciphertext) + aes.final

        JSON.parse(plaintext)
      }

      expect { decrypt.call }.to_not raise_error

      data = decrypt.call

      expect(data).to_not be_nil
      expect(data).to include(
        'meta' => include(
          'iat' => a_kind_of(String),
          'exp' => a_kind_of(String),
          'ttl' => a_kind_of(Integer),
        ),
        'data' => include(
          'type' => 'licenses',
          'id' => license.id,
        ),
      )
    end
  end

  context 'when including relationships' do
    it 'should not return the included relationships' do
      cert = LicenseCheckoutService.call(
        account: account,
        license: license,
        include: [],
      )

      payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                    .delete_suffix("-----END LICENSE FILE-----\n")

      json = JSON.parse(Base64.decode64(payload))
      enc  = json.fetch('enc')
      data = nil

      expect { data = JSON.parse(Base64.strict_decode64(enc)) }.to_not raise_error

      expect(data).to_not be_nil
      expect(data).to_not have_key('included')
      expect(data).to include(
        'meta' => include(
          'iat' => a_kind_of(String),
          'exp' => a_kind_of(String),
          'ttl' => a_kind_of(Integer),
        ),
        'data' => include(
          'type' => 'licenses',
          'id' => license.id,
        ),
      )
    end

    it 'should return the included relationships' do
      cert = LicenseCheckoutService.call(
        account: account,
        license: license,
        include: %w[
          product
          policy
        ],
      )

      payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                    .delete_suffix("-----END LICENSE FILE-----\n")

      json = JSON.parse(Base64.decode64(payload))
      enc  = json.fetch('enc')
      data = nil

      expect { data = JSON.parse(Base64.strict_decode64(enc)) }.to_not raise_error

      expect(data).to_not be_nil
      expect(data).to include(
        'included' => include(
          include('type' => 'products', 'id' => license.product.id),
          include('type' => 'policies', 'id' => license.policy.id),
        ),
        'meta' => include(
          'iat' => a_kind_of(String),
          'exp' => a_kind_of(String),
          'ttl' => a_kind_of(Integer),
        ),
        'data' => include(
          'type' => 'licenses',
          'id' => license.id,
        ),
      )
    end
  end

  context 'when using a TTL' do
    it 'should return a cert that expires after the default TTL' do
      freeze_time do
        cert = LicenseCheckoutService.call(
          account: account,
          license: license,
        )

        payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                      .delete_suffix("-----END LICENSE FILE-----\n")

        json = JSON.parse(Base64.decode64(payload))
        enc  = json.fetch('enc')
        data = nil

        expect { data = JSON.parse(Base64.strict_decode64(enc)) }.to_not raise_error

        expect(data).to_not be_nil
        expect(data).to include(
          'meta' => include(
            'iat' => Time.current,
            'exp' => 1.month.from_now,
            'ttl' => 1.month,
          ),
        )
      end
    end

    it 'should return a cert that expires after a custom TTL' do
      freeze_time do
        cert = LicenseCheckoutService.call(
          account: account,
          license: license,
          ttl: 1.week,
        )

        payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                      .delete_suffix("-----END LICENSE FILE-----\n")

        json = JSON.parse(Base64.decode64(payload))
        enc  = json.fetch('enc')
        data = nil

        expect { data = JSON.parse(Base64.strict_decode64(enc)) }.to_not raise_error

        expect(data).to_not be_nil
        expect(data).to include(
          'meta' => include(
            'iat' => Time.current,
            'exp' => 1.week.from_now,
            'ttl' => 1.week,
          ),
        )
      end
    end

    it 'should return a cert that has no TTL' do
      freeze_time do
        cert = LicenseCheckoutService.call(
          account: account,
          license: license,
          ttl: nil,
        )

        payload = cert.delete_prefix("-----BEGIN LICENSE FILE-----\n")
                      .delete_suffix("-----END LICENSE FILE-----\n")

        json = JSON.parse(Base64.decode64(payload))
        enc  = json.fetch('enc')
        data = nil

        expect { data = JSON.parse(Base64.strict_decode64(enc)) }.to_not raise_error

        expect(data).to_not be_nil
        expect(data).to include(
          'meta' => include(
            'iat' => Time.current,
            'exp' => nil,
            'ttl' => nil,
          ),
        )
      end
    end
  end
end