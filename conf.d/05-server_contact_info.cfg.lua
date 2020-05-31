local domain = os.getenv("DOMAIN")

contact_info = {
  abuse = { "xmpp:abuse@" .. domain };
  admin = { "xmpp:admin@" .. domain };
  feedback = { "xmpp:feedback@" .. domain };
  sales = { "xmpp:sales@" .. domain };
  security = { "xmpp:security@" .. domain };
  support = { "xmpp:support@" .. domain };
}
