import { PrismaClient, Role } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Admin
  const adminHash = await bcrypt.hash('admin123', 12);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@tiendacuba.cu' },
    update: {},
    create: {
      email: 'admin@tiendacuba.cu',
      passwordHash: adminHash,
      firstName: 'Admin',
      lastName: 'Tienda',
      role: Role.SUPER_ADMIN,
      phone: '53000000',
    },
  });
  console.log('Admin creado:', admin.email);

  // Cliente demo
  const customerHash = await bcrypt.hash('cliente123', 12);
  await prisma.user.upsert({
    where: { email: 'cliente@ejemplo.cu' },
    update: {},
    create: {
      email: 'cliente@ejemplo.cu',
      passwordHash: customerHash,
      firstName: 'Juan',
      lastName: 'Pérez',
      role: Role.CUSTOMER,
      phone: '53555555',
    },
  });

  // Categorías
  const catElectro = await prisma.category.upsert({
    where: { slug: 'electrodomesticos' },
    update: {},
    create: {
      name: 'Electrodomésticos',
      slug: 'electrodomesticos',
      description: 'Electrodomésticos para el hogar',
    },
  });

  const catRopa = await prisma.category.upsert({
    where: { slug: 'ropa' },
    update: {},
    create: {
      name: 'Ropa',
      slug: 'ropa',
      description: 'Ropa y accesorios',
    },
  });

  const catAlimentos = await prisma.category.upsert({
    where: { slug: 'alimentos' },
    update: {},
    create: {
      name: 'Alimentos',
      slug: 'alimentos',
      description: 'Alimentos y bebidas',
    },
  });

  // Productos de ejemplo
  const products = [
    {
      name: 'Licuadora Oster 10 velocidades',
      slug: 'licuadora-oster-10',
      description: 'Licuadora potente con vaso de vidrio y 10 velocidades.',
      priceCUP: 18500,
      priceMLC: 45,
      priceUSDT: 45,
      stock: 15,
      images: ['https://via.placeholder.com/400x400?text=Licuadora'],
      categoryId: catElectro.id,
    },
    {
      name: 'Aire acondicionado 1 tonelada',
      slug: 'aire-acondicionado-1t',
      description: 'Aire acondicionado split 12000 BTU, eficiente.',
      priceCUP: 95000,
      priceMLC: 280,
      priceUSDT: 280,
      stock: 5,
      images: ['https://via.placeholder.com/400x400?text=Aire'],
      categoryId: catElectro.id,
    },
    {
      name: 'Camiseta polo hombre',
      slug: 'camiseta-polo-hombre',
      description: 'Camiseta polo de algodón, varias tallas.',
      priceCUP: 2800,
      priceMLC: 8,
      priceUSDT: 8,
      stock: 50,
      images: ['https://via.placeholder.com/400x400?text=Polo'],
      categoryId: catRopa.id,
    },
    {
      name: 'Arroz 5 kg',
      slug: 'arroz-5kg',
      description: 'Arroz de grano largo, paquete de 5 kilogramos.',
      priceCUP: 1200,
      priceMLC: 3.5,
      priceUSDT: 3.5,
      stock: 100,
      images: ['https://via.placeholder.com/400x400?text=Arroz'],
      categoryId: catAlimentos.id,
    },
    {
      name: 'Aceite de cocina 1L',
      slug: 'aceite-1l',
      description: 'Aceite vegetal refinado, botella de 1 litro.',
      priceCUP: 950,
      priceMLC: 2.8,
      priceUSDT: 2.8,
      stock: 80,
      images: ['https://via.placeholder.com/400x400?text=Aceite'],
      categoryId: catAlimentos.id,
    },
  ];

  for (const p of products) {
    await prisma.product.upsert({
      where: { slug: p.slug },
      update: {},
      create: p,
    });
  }

  console.log('✅ Seed completado');
  console.log('Admin: admin@tiendacuba.cu / admin123');
  console.log('Cliente: cliente@ejemplo.cu / cliente123');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
