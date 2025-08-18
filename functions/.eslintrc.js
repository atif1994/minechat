module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
    "plugin:@typescript-eslint/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["tsconfig.json", "tsconfig.dev.json"],
    sourceType: "module",
  },
  ignorePatterns: [
    "/lib/**/*", // Ignore built files.
    "/generated/**/*", // Ignore generated files.
  ],
  plugins: [
    "@typescript-eslint",
    "import",
  ],
  rules: {
    "quotes": ["error", "double"],
    "import/no-unresolved": 0,
    "indent": ["error", 2],
    "max-len": ["error", { code: 120, ignoreStrings: true, ignoreTemplateLiterals: true }],
    "require-jsdoc": "off", // stop demanding JSDoc on every function
    "object-curly-spacing": ["error", "always"], // allow { ok: true }
    "operator-linebreak": "off", // don't fight over ?/: line breaks
    "@typescript-eslint/no-unused-vars": ["warn", { argsIgnorePattern: "^_" }], // silence _context warnings
  },
};
