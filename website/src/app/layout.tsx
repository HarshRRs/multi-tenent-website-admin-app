import type { Metadata } from "next";
import { Inter } from "next/font/google";
import { RestaurantProvider } from "@/contexts/restaurant-context";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Restaurant - Order Online",
  description: "Experience culinary excellence with our handcrafted dishes",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="scroll-smooth">
      <body className={inter.className}>
        <RestaurantProvider>
          {children}
        </RestaurantProvider>
      </body>
    </html>
  );
}
