/*
  Warnings:

  - A unique constraint covering the columns `[slug]` on the table `User` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE "Order" ADD COLUMN     "customerEmail" TEXT,
ADD COLUMN     "customerPhone" TEXT,
ADD COLUMN     "deliveryAddress" TEXT,
ADD COLUMN     "paymentMethod" TEXT NOT NULL DEFAULT 'cash',
ADD COLUMN     "paymentStatus" TEXT NOT NULL DEFAULT 'pending',
ADD COLUMN     "stripePaymentIntentId" TEXT;

-- AlterTable
ALTER TABLE "Reservation" ADD COLUMN     "customerEmail" TEXT,
ADD COLUMN     "customerPhone" TEXT;

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "address" TEXT,
ADD COLUMN     "businessType" TEXT NOT NULL DEFAULT 'restaurant',
ADD COLUMN     "isStoreOpen" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "slug" TEXT;

-- AlterTable
ALTER TABLE "WebsiteConfig" ADD COLUMN     "deliveryRadiusKm" DOUBLE PRECISION NOT NULL DEFAULT 10.0;

-- CreateTable
CREATE TABLE "PasswordReset" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PasswordReset_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_slug_key" ON "User"("slug");

-- CreateIndex
CREATE INDEX "User_slug_idx" ON "User"("slug");
