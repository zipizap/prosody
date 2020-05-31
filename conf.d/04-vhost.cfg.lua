local domain = os.getenv("DOMAIN")

ssl = {
	key = "/usr/local/etc/prosody/certs/prosody.key";
	certificate = "/usr/local/etc/prosody/certs/prosody.crt";
}

VirtualHost (domain)

-- Set up a SOCKS5 bytestream proxy for server-proxied file transfers
Component ("proxy." .. domain) "proxy65"
	proxy65_address = "proxy." .. domain
	proxy65_acl = { domain }

-- Set up a http file upload because proxy65 is not working in muc
Component ("upload." .. domain) "http_upload"
	http_upload_expire_after = 60 * 60 * 24 * 7 -- a week in seconds

Component ("conference." .. domain) "muc"
	name = "Prosody Chatrooms"
	restrict_room_creation = false
	max_history_messages = 20
	modules_enabled = {
		"muc_mam",
		"vcard_muc"
	}
