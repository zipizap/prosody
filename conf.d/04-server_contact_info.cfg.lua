local domain = os.getenv("DOMAIN")

contact_info = {
  abuse = { os.getenv("SERVER_CONTACT_INFO_ABUSE") };
  admin = { os.getenv("SERVER_CONTACT_INFO_ADMIN") };
  feedback = { os.getenv("SERVER_CONTACT_INFO_FEEDBACK") };
  sales = { os.getenv("SERVER_CONTACT_INFO_SALES") };
  security = { os.getenv("SERVER_CONTACT_INFO_SECURITY") };
  support = { os.getenv("SERVER_CONTACT_INFO_SUPPORT") };
}
