import { Prisma, PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const tables = ["Settings"];

const settings = [
  {
    name: "scraper",
    value: JSON.stringify({ 
      access: "public",
      whitelistPaths: ["assets"],
      allowedRoles: ["admin"],
    }),
  },
];

async function main() {
  await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
    console.log("Clear data in tables");
    await clearData(tx);
    console.log("Insert seed data to database");
    await seedData(tx);
  },
    {
      timeout: 60000
    });
}

async function clearData(tx: Prisma.TransactionClient) { // SQLite
  for (const table of tables) {
    // Clear table
    const query = `DELETE FROM "${table}";`; // Change TRUNCATE to DELETE
    await tx.$queryRaw(Prisma.sql`${Prisma.raw(query)}`);
    console.log(query);
    
    // Reset auto-incrementing IDs (since SQLite does not support TRUNCATE's behavior)
    const resetQuery = `DELETE FROM sqlite_sequence WHERE name='${table}';`;
    await tx.$queryRaw(Prisma.sql`${Prisma.raw(resetQuery)}`);
    console.log(resetQuery);
  }
}

async function seedData(tx: Prisma.TransactionClient) {
  let results;
  results = await tx.settings.createMany({
    data: settings
  });
  console.log(`${results.count} records created in Settings`);
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });
