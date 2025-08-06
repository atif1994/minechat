class AppAssets {
  // ===== MINECHAT BRAND LOGOS =====
  // Main brand logos
  static const String minechatLogoWhite = 'assets/images/logos/logo_minechat_white.svg';
  static const String minechatLogoColored = 'assets/images/logos/logo_minechat_colored.svg';
  static const String minechatLogoSmall = 'assets/images/logos/logo_minechat_small.svg';
  static const String minechatlogo = 'assets/images/logos/minechat.svg';
  static const String lightDart = 'assets/images/logos/lightandDarkLogo.svg';
  static const String minechatLogoDummy = "assets/images/logos/dummy_logo.png";
  static const String darkMode = "assets/images/logos/darkmode.svg";



  // ===== SOCIAL MEDIA ICONS =====
  // Dark theme versions (white icons)
  static const String socialMessengerDark = 'assets/images/logos/logo_messenger.svg';
  static const String mineChatCamera = "assets/images/logos/camera.svg";
  static const String mineChatWorld = "assets/images/logos/world.svg";
  static const String socialInstagramDark = 'assets/images/logos/logo_instagram.svg';
  static const String socialTelegramDark = 'assets/images/logos/logo_telegram.svg';
  static const String socialDiscordDark = 'assets/images/logos/logo_discord.svg';
  static const String socialSlackDark = 'assets/images/logos/logo_slack.svg';
  static const String socialWhatsappDark = 'assets/images/logos/logo_whatsapp.svg';
  static const String socialViberDark = 'assets/images/logos/logo_viber.svg';
  // Light theme versions (colored icons) - same files but different styling
  static const String socialMessengerLight = 'assets/images/logos/logo_messenger.svg';
  static const String socialInstagramLight = 'assets/images/logos/logo_instagram.svg';
  static const String socialTelegramLight = 'assets/images/logos/logo_telegram.svg';
  static const String socialDiscordLight = 'assets/images/logos/logo_discord.svg';
  static const String socialSlackLight = 'assets/images/logos/logo_slack.svg';
  static const String socialWhatsappLight = 'assets/images/logos/logo_whatsapp.svg';
  static const String socialViberLight = 'assets/images/logos/logo_viber.svg';

  // ===== GRID PATTERNS =====
  static const String gridPatternUpper = 'assets/images/grids/grid_upper.svg';
  static const String gridPatternLower = 'assets/images/grids/grid_lower.svg';

  // ===== THEME-SPECIFIC GETTERS =====
  static const String logoMinechatSmall =
      'assets/images/logos/logo_minechat_small.svg';
  // Main logo getter
  static String getMinechatLogo(bool isDark) {
    return isDark ? minechatLogoWhite : minechatLogoColored;
  }

  // Social media icons getters
  static String getSocialIcon(String platform, bool isDark) {
    switch (platform.toLowerCase()) {
      case 'messenger':
        return isDark ? socialMessengerDark : socialMessengerLight;
      case 'instagram':
        return isDark ? socialInstagramDark : socialInstagramLight;
      case 'telegram':
        return isDark ? socialTelegramDark : socialTelegramLight;
      case 'discord':
        return isDark ? socialDiscordDark : socialDiscordLight;
      case 'slack':
        return isDark ? socialSlackDark : socialSlackLight;
      case 'whatsapp':
        return isDark ? socialWhatsappDark : socialWhatsappLight;
      case 'viber':
        return isDark ? socialViberDark : socialViberLight;
      case 'camera':
        return isDark ? mineChatCamera : mineChatCamera ;
      case 'world':
        return isDark ? mineChatWorld : mineChatWorld ;
      default:
        return isDark ? socialMessengerDark : socialMessengerLight;
    }
  }

  // All social media icons list for floating animation
  static List<String> getSocialMediaIcons(bool isDark) {
    return [
      getSocialIcon('messenger', isDark),
      getSocialIcon('instagram', isDark),
      getSocialIcon('telegram', isDark),
      getSocialIcon('discord', isDark),
      getSocialIcon('slack', isDark),
      getSocialIcon('whatsapp', isDark),
      getSocialIcon('viber', isDark),
    ];
  }

  // Social media platform names for mapping
  static List<String> get socialMediaPlatforms => [
    'messenger',
    'instagram',
    'telegram',
    'discord',
    'slack',
    'whatsapp',
    'viber',
  ];

  // Signup Screen Icons
  static const String signupIconCompany = 'assets/images/icons/icon_company.svg';
  static const String signupIconPhone = 'assets/images/icons/icon_phone.svg';
  static const String signupIconAdmin = 'assets/images/icons/icon_admin.svg';
  static const String signupIconPosition = 'assets/images/icons/icon_position.svg';
  static const String signupIconEmail = 'assets/images/icons/icon_email.svg';
  static const String signupIconPassword = 'assets/images/icons/icon_password.svg';

}
