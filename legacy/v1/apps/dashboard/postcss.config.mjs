// Tailwind v4 PostCSS plugin registration. Without this file, Next.js compiles
// app/globals.css through the default PostCSS chain and `@import "tailwindcss"`
// silently does nothing — leaving every page unstyled.
const config = {
  plugins: {
    '@tailwindcss/postcss': {},
  },
};

export default config;
