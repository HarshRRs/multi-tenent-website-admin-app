const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    const user = await prisma.user.findUnique({
        where: { email: 'jainhatu@gmail.com' },
    });
    console.log(user ? 'User found: ' + JSON.stringify(user, null, 2) : 'User not found');
}

main()
    .catch(e => console.error(e))
    .finally(async () => await prisma.$disconnect());
