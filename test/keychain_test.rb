require "test/unit"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'keychain_manager'

class KeychainManagerTest < Test::Unit::TestCase

  def setup
    # Do nothing
  end

  def teardown

  end

  def test_create_delete_exists
    kcm = KeychainManager.new("some_keychain")
    assert !kcm.exists?, "keychain already exists"
    kcm.create
    assert kcm.exists?, "keychain should be created"
    kcm.delete
    assert !kcm.exists?, "keychain should be deleted"
  end


  def test_generate_rsa_key
    rsa_tmp = '/tmp/test.rsa'
    File.delete(rsa_tmp) if File.exists?(rsa_tmp)
    KeychainManager.generate_rsa_key(rsa_tmp, 2048)
    assert File.exists?(rsa_tmp)
  end

  def test_generate_cert_request
    rsa_tmp = '/tmp/test.rsa'
    File.delete(rsa_tmp) if File.exists?(rsa_tmp)
    KeychainManager.generate_rsa_key(rsa_tmp, 2048)

    cert_tmp = '/tmp/test.cert'
    File.delete(cert_tmp) if File.exists?(cert_tmp)
    KeychainManager.generate_cert_request('partners@reflect7.com', 'US', rsa_tmp, cert_tmp)

    csr_plain_text = `openssl req -in /tmp/test.cert -noout -text`
    assert csr_plain_text.include?("Subject: emailAddress=partners@reflect7.com, CN=partners@reflect7.com, C=US")
    assert File.exists?(cert_tmp)
  end

  def test_import_rsa_key
    rsa_tmp = '/tmp/test.rsa'
    KeychainManager.generate_rsa_key(rsa_tmp, 2048)

    kcm = KeychainManager.new("some_keychain")
    kcm.create
    assert kcm.import_rsa_key(rsa_tmp).include?('1 key imported')
    kcm.delete
  end
end
