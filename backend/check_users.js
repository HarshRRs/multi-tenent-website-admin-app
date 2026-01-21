const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    const count = await prisma.user.count();
    console.log(`Total users in DB: ${count}`);

    if (count > 0) {
        const users = await prisma.user.findMany({
            select: { email: true, name: true }
        });
        console.log('Users:', users);
    }
}

main()
    .catch(e => console.error(e))
    .finally(async () => await prisma.$disconnect());
