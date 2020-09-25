-- see example config at https://hg.prosody.im/0.9/file/0.9.10/prosody.cfg.lua.dist
-- easily extendable by putting into different config files within conf.d folder

admins = { os.getenv("PROSODY_ADMINS") };

use_libevent = true; -- improves performance

allow_registration = os.getenv("ALLOW_REGISTRATION");

c2s_require_encryption = os.getenv("C2S_REQUIRE_ENCRYPTION");
s2s_require_encryption = os.getenv("S2S_REQUIRE_ENCRYPTION");
s2s_secure_auth = os.getenv("S2S_SECURE_AUTH");

authentication = "internal_hashed";

log = {
    {levels = {min = os.getenv("LOG_LEVEL")}, to = "console"};
};

--- 
http_upload_file_size_limit = 500971520
http_max_content_size = 701457280

Include "conf.d/*.cfg.lua";
