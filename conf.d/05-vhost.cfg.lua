local domain = os.getenv("DOMAIN")
local domain_http_upload = os.getenv("DOMAIN_HTTP_UPLOAD")
local domain_muc = os.getenv("DOMAIN_MUC")
local domain_proxy = os.getenv("DOMAIN_PROXY")

-- This is a fallback just for http_upload because service certificates are searched differently
-- https://prosody.im/doc/certificates#service_certificates
ssl = {
	certificate = "certs/" .. domain .. "/fullchain.pem";
	key = "certs/" .. domain .. "/privkey.pem";
}

-- XEP-0368: SRV records for XMPP over TLS
-- https://compliance.conversations.im/test/xep0368/
legacy_ssl_ports = { 5223 }

VirtualHost (domain)

-- Set up a http file upload because proxy65 is not working in muc
Component (domain_http_upload) "http_upload"
	http_upload_expire_after = 60 * 60 * 24 * 7 -- a week in seconds

Component (domain_muc) "muc"
	name = "Prosody Chatrooms"
	restrict_room_creation = false
	max_history_messages = 20
	modules_enabled = {
		"muc_mam",
		"vcard_muc"
	}

-- Set up a SOCKS5 bytestream proxy for server-proxied file transfers
Component (domain_proxy) "proxy65"
	proxy65_address = domain_proxy
	proxy65_acl = { domain }