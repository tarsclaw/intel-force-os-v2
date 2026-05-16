import type { Metadata } from 'next';
import { ClerkProvider } from '@clerk/nextjs';
// NOTE: @clerk/themes is intentionally NOT imported. The `variables` block
// below carries the colours we'd otherwise inherit from the `dark` preset.
// To re-enable the official preset:
//   pnpm --filter @intelforce/dashboard add @clerk/themes
//   import { dark } from '@clerk/themes';   then add baseTheme: dark below.
import { Fraunces, Geist, JetBrains_Mono } from 'next/font/google';
import { Providers } from '../components/providers';
import './globals.css';

const geist = Geist({ subsets: ['latin'], variable: '--font-geist', display: 'swap' });
// Fraunces is a variable font. When axes are listed, weight must be omitted
// (or set to 'variable') — next/font fetches the full variable axis range.
const fraunces = Fraunces({
  subsets: ['latin'],
  variable: '--font-fraunces',
  axes: ['opsz'],
  display: 'swap',
});
const mono = JetBrains_Mono({
  subsets: ['latin'],
  variable: '--font-mono',
  weight: ['400', '500'],
  display: 'swap',
});

export const metadata: Metadata = {
  title: { default: 'Intel Force OS', template: '%s | Intel Force OS' },
  description: 'AI-assisted HR operations for UK SMEs',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <ClerkProvider
      appearance={{
        variables: {
          colorBackground: '#07090b',
          colorPrimary: '#10b981',
          colorText: '#fafafa',
          colorTextSecondary: '#a1a1aa',
          colorTextOnPrimaryBackground: '#022c22',
          colorInputBackground: '#0d1014',
          colorInputText: '#fafafa',
          colorNeutral: '#fafafa',
          colorDanger: '#ef4444',
          colorSuccess: '#10b981',
          colorWarning: '#f59e0b',
          borderRadius: '0.5rem',
        },
        elements: {
          card: 'bg-[rgb(13,16,20)] ring-1 ring-white/5',
          headerTitle: 'text-white',
          socialButtonsBlockButton: 'bg-white/[0.04] border border-white/10 text-white hover:bg-white/[0.08]',
          formFieldInput: 'bg-[rgb(13,16,20)] border border-white/10 text-white',
        },
      }}
    >
      <html lang="en" className={`dark ${geist.variable} ${fraunces.variable} ${mono.variable}`}>
        <body>
          <Providers>{children}</Providers>
        </body>
      </html>
    </ClerkProvider>
  );
}
