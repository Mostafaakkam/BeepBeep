/**
 * seed.js
 * ---------------------------------------------------------------------------
 * سكربت بيانات وهمية (Seed Data) لمشروع Beep Beep.
 *
 * الهدف: تعبئة قاعدة بيانات "beep_beep" ببيانات تجريبية واقعية (مستخدمين،
 * متاجر، تصنيفات، منتجات، صور، متغيرات، عناوين، مفضلة، سلة تسوق) لتجربة
 * التطبيق وعرضه بشكل واقعي أثناء التطوير.
 *
 * ⚠️ تحذير: هذا السكربت يقوم بتفريغ (TRUNCATE) الجداول التالية بالكامل قبل
 * إعادة تعبئتها: cart_items, carts, favorites, product_variants,
 * product_images, products, categories, stores, users, addresses.
 * لا تشغّله على قاعدة بيانات إنتاج تحتوي على بيانات حقيقية.
 *
 * ملاحظة: السكربت لا يلمس جدولي orders و order_items (لا يقوم بحذفهما ولا
 * بإضافة بيانات لهما)، حتى لا يفقد أي سجل طلبات حقيقي أثناء التجربة. لكن إن
 * كانت هذه الجداول تحتوي على طلبات قديمة تُشير إلى منتجات/متاجر سيتم حذفها
 * الآن، فقد تصبح تلك الإشارات يتيمة (orphaned) — وهذا متوقع في بيئة تطوير.
 *
 * التشغيل:
 *   cd backend
 *   node src/seeders/seed.js
 *
 * المتطلبات: ملف backend/.env معبأ ببيانات الاتصال بقاعدة MySQL المحلية
 * (نفس الإعدادات التي يستخدمها السيرفر في backend/src/config/database.js).
 * ---------------------------------------------------------------------------
 */

require('dotenv').config();

const bcrypt = require('bcrypt');
const pool = require('../config/database');

const SEED_PASSWORD = 'password123';
const BCRYPT_ROUNDS = 10; // نفس القيمة المستخدمة في authService.js

// =============================================================================
// أدوات مساعدة عامة (Helpers)
// =============================================================================

/**
 * كاش لأعمدة كل جدول، حتى لا نستعلم عن نفس الجدول أكثر من مرة.
 */
const tableColumnsCache = {};

/**
 * يعيد مجموعة (Set) بأسماء الأعمدة الموجودة فعلياً في جدول معيّن.
 * نعتمد على INFORMATION_SCHEMA بدلاً من افتراض بنية ثابتة، لأن بعض الأعمدة
 * الاختيارية (مثل product_images.is_primary أو categories.parent_id) قد
 * تكون موجودة في قاعدة بياناتك أو لا تكون، حسب آخر تحديث للـ Schema.
 * هذا يجعل السكربت متوافقاً تلقائياً مع القاعدة الفعلية بدل أن يفشل بخطأ
 * "Unknown column".
 */
async function getTableColumns(table) {
  if (tableColumnsCache[table]) return tableColumnsCache[table];

  const [rows] = await pool.query(
    `SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?`,
    [table]
  );

  if (rows.length === 0) {
    throw new Error(
      `الجدول "${table}" غير موجود في قاعدة البيانات الحالية. تأكد من أنك شغّلت السكربت على قاعدة "beep_beep" الصحيحة وأن الجداول تم إنشاؤها مسبقاً.`
    );
  }

  const columns = new Set(rows.map((r) => r.COLUMN_NAME));
  tableColumnsCache[table] = columns;
  return columns;
}

/**
 * يدرج صفاً واحداً في الجدول المحدد، مع تصفية أي مفاتيح في `data` لا تقابل
 * عموداً حقيقياً في الجدول (بدلاً من تفجير السكربت بخطأ SQL). يطبع تحذيراً
 * عند تجاهل أي عمود، حتى تكون على اطلاع.
 */
async function insertRow(table, data) {
  const columns = await getTableColumns(table);

  const keys = Object.keys(data).filter((k) => columns.has(k));
  const skipped = Object.keys(data).filter((k) => !columns.has(k));

  if (skipped.length > 0) {
    console.log(
      `   ⚠️  تجاهل أعمدة غير موجودة في جدول "${table}": ${skipped.join(', ')}`
    );
  }

  const columnList = keys.map((k) => `\`${k}\``).join(', ');
  const placeholders = keys.map(() => '?').join(', ');
  const values = keys.map((k) => data[k]);

  const [result] = await pool.execute(
    `INSERT INTO \`${table}\` (${columnList}) VALUES (${placeholders})`,
    values
  );

  return result.insertId;
}

/** يفرغ جدولاً بالكامل (مع تجاوز فحص المفاتيح الأجنبية مؤقتاً). */
async function truncateTable(table) {
  await pool.query(`TRUNCATE TABLE \`${table}\``);
  console.log(`   🗑️  تم تفريغ جدول "${table}"`);
}

// =============================================================================
// البيانات الوهمية (Seed Data)
// =============================================================================

// `key` and `role` are new (Store Ownership / Role-Based Authorization
// feature). `key` lets storesData below reference a specific seeded user as
// a store's owner without depending on array order/insert IDs. `role`
// defaults to 'customer' when omitted, unchanged from before.
const usersData = [
  { key: 'ahmad', name: 'أحمد الحلبي', phone: '00963991234567', email: 'ahmad.halabi@example.com', role: 'store_owner' },
  { key: 'sara', name: 'سارة يوسف', phone: '00963991234568', email: 'sara.yousef@example.com', role: 'store_owner' },
  { key: 'mohammad', name: 'محمد العلي', phone: '00963991234569', email: 'mohammad.ali@example.com' },
  { key: 'layla', name: 'ليلى إبراهيم', phone: '00963991234570', email: 'layla.ibrahim@example.com' },
  { key: 'omar', name: 'عمر الخطيب', phone: '00963991234571', email: 'omar.khatib@example.com' },
];

// `ownerKey` (new, Store Ownership feature) references a `key` from
// usersData above and is resolved to that user's real id after users are
// inserted. Left unset on purpose for 'electronics' and 'gifts' to also
// seed the "store with no owner assigned yet" case. 'fashion' and 'perfume'
// share the same owner ('ahmad') to demonstrate one store_owner legitimately
// owning multiple stores, which this feature intentionally allows.
const storesData = [
  {
    key: 'fashion',
    name: 'متجر الأزياء الحديثة',
    description: 'أحدث صيحات الموضة للرجال والنساء بأسعار مناسبة وجودة عالية.',
    phone: '00963112345601',
    address: 'شارع الكواكبي، حلب',
    status: 'active',
    ownerKey: 'ahmad',
  },
  {
    key: 'shoes',
    name: 'متجر الأحذية الفاخرة',
    description: 'تشكيلة واسعة من الأحذية الرجالية والنسائية الفاخرة والرياضية.',
    phone: '00963112345602',
    address: 'شارع الحلبوني، حلب',
    status: 'active',
    ownerKey: 'sara',
  },
  {
    key: 'electronics',
    name: 'متجر الإلكترونيات والتقنية',
    description: 'أحدث الهواتف الذكية والإكسسوارات التقنية وأجهزة المنزل الذكية.',
    phone: '00963112345603',
    address: 'شارع سعد الله الجابري، حلب',
    status: 'active',
  },
  {
    key: 'perfume',
    name: 'متجر العطور ومستحضرات التجميل',
    description: 'عطور شرقية وغربية أصلية إلى جانب مستحضرات تجميل فاخرة.',
    phone: '00963112345604',
    address: 'شارع بارون، حلب',
    status: 'active',
    ownerKey: 'ahmad',
  },
  {
    key: 'gifts',
    name: 'متجر الهدايا والألعاب',
    description: 'متجر جديد قيد المراجعة لهدايا وألعاب الأطفال.',
    phone: '00963112345605',
    address: 'شارع النيل، حلب',
    status: 'pending',
  },
];

const categoriesData = [
  'أزياء رجالية',
  'أزياء نسائية',
  'أحذية',
  'إلكترونيات',
  'عطور',
  'مستحضرات تجميل',
  'ألعاب',
];

// كل منتج يشير إلى متجر (عبر key من storesData) وتصنيف (بالاسم من categoriesData).
// جميع المنتجات مرتبطة بمتاجر status = 'active' فقط، كما هو مطلوب.
const productsData = [
  // ---------------- متجر الأزياء الحديثة ----------------
  {
    storeKey: 'fashion',
    category: 'أزياء رجالية',
    name: 'قميص قطني رجالي أبيض',
    description: 'قميص قطني ناعم ومريح، مناسب للاستخدام اليومي والمناسبات الرسمية.',
    variants: [
      { color: 'أبيض', size: 'M', price: 25, stock: 30 },
      { color: 'أبيض', size: 'L', price: 25, stock: 20 },
      { color: 'أبيض', size: 'XL', price: 27, stock: 15 },
    ],
  },
  {
    storeKey: 'fashion',
    category: 'أزياء رجالية',
    name: 'قميص قطني رجالي أسود',
    description: 'قميص قطني أنيق بلون أسود كلاسيكي يناسب جميع المناسبات.',
    variants: [
      { color: 'أسود', size: 'M', price: 25, stock: 25 },
      { color: 'أسود', size: 'L', price: 25, stock: 18 },
    ],
  },
  {
    storeKey: 'fashion',
    category: 'أزياء رجالية',
    name: 'جينز رجالي عصري',
    description: 'بنطال جينز عصري بقصة مريحة وخامة متينة عالية الجودة.',
    variants: [
      { color: 'أزرق غامق', size: '32', price: 40, stock: 20 },
      { color: 'أزرق غامق', size: '34', price: 40, stock: 15 },
      { color: 'أزرق فاتح', size: '36', price: 42, stock: 10 },
    ],
  },
  {
    storeKey: 'fashion',
    category: 'أزياء نسائية',
    name: 'فستان صيفي أنيق',
    description: 'فستان صيفي خفيف بتصميم أنيق يناسب الإطلالات النهارية.',
    variants: [
      { color: 'أحمر', size: 'S', price: 35, stock: 12 },
      { color: 'أسود', size: 'M', price: 35, stock: 18 },
    ],
  },
  {
    storeKey: 'fashion',
    category: 'أزياء نسائية',
    name: 'بلوزة نسائية كاجوال',
    description: 'بلوزة قطنية مريحة بألوان هادئة تناسب الإطلالات اليومية.',
    variants: [
      { color: 'أبيض', size: 'S', price: 28, stock: 22 },
      { color: 'وردي', size: 'M', price: 28, stock: 14 },
    ],
  },

  // ---------------- متجر الأحذية الفاخرة ----------------
  {
    storeKey: 'shoes',
    category: 'أحذية',
    name: 'حذاء رياضي رجالي',
    description: 'حذاء رياضي خفيف ومريح مناسب للجري والاستخدام اليومي.',
    variants: [
      { color: 'أسود', size: '42', price: 35, stock: 25 },
      { color: 'أسود', size: '43', price: 35, stock: 20 },
      { color: 'أبيض', size: '44', price: 37, stock: 10 },
    ],
  },
  {
    storeKey: 'shoes',
    category: 'أحذية',
    name: 'حذاء كلاسيكي جلد طبيعي',
    description: 'حذاء رجالي كلاسيكي مصنوع من الجلد الطبيعي مناسب للمناسبات الرسمية.',
    variants: [
      { color: 'بني', size: '41', price: 50, stock: 8 },
      { color: 'أسود', size: '42', price: 50, stock: 12 },
    ],
  },
  {
    storeKey: 'shoes',
    category: 'أحذية',
    name: 'حذاء نسائي كعب عالي',
    description: 'حذاء نسائي أنيق بكعب عالٍ مناسب للسهرات والمناسبات.',
    variants: [
      { color: 'أسود', size: '37', price: 45, stock: 10 },
      { color: 'بيج', size: '38', price: 45, stock: 6 },
      { color: 'أسود', size: '39', price: 47, stock: 5 },
    ],
  },

  // ---------------- متجر الإلكترونيات والتقنية ----------------
  {
    storeKey: 'electronics',
    category: 'إلكترونيات',
    name: 'هاتف ذكي الجيل الجديد',
    description: 'هاتف ذكي بمواصفات قوية وكاميرا عالية الدقة وبطارية تدوم طويلاً.',
    variants: [
      { color: 'أسود', size: '128GB', price: 150, stock: 15 },
      { color: 'أزرق', size: '256GB', price: 170, stock: 8 },
    ],
  },
  {
    storeKey: 'electronics',
    category: 'إلكترونيات',
    name: 'سماعات لاسلكية بلوتوث',
    description: 'سماعات لاسلكية بجودة صوت عالية وعزل ضوضاء ممتاز.',
    variants: [
      { color: 'أسود', size: 'مقاس واحد', price: 20, stock: 40 },
      { color: 'أبيض', size: 'مقاس واحد', price: 20, stock: 35 },
    ],
  },
  {
    storeKey: 'electronics',
    category: 'إلكترونيات',
    name: 'ساعة ذكية رياضية',
    description: 'ساعة ذكية لمتابعة اللياقة البدنية ومعدل ضربات القلب والإشعارات.',
    variants: [
      { color: 'أسود', size: 'مقاس واحد', price: 60, stock: 18 },
      { color: 'فضي', size: 'مقاس واحد', price: 65, stock: 10 },
    ],
  },
  {
    storeKey: 'electronics',
    category: 'ألعاب',
    name: 'لعبة تعليمية إلكترونية للأطفال',
    description: 'لعبة إلكترونية تفاعلية تساعد الأطفال على التعلم والاستكشاف بمتعة.',
    variants: [
      { color: 'متعدد الألوان', size: 'مقاس واحد', price: 15, stock: 30 },
      { color: 'أزرق', size: 'مقاس واحد', price: 15, stock: 20 },
    ],
  },

  // ---------------- متجر العطور ومستحضرات التجميل ----------------
  {
    storeKey: 'perfume',
    category: 'عطور',
    name: 'عطر رجالي فاخر',
    description: 'عطر رجالي بتركيبة خشبية فاخرة يدوم طويلاً.',
    variants: [
      { color: 'غير محدد', size: '50ml', price: 30, stock: 20 },
      { color: 'غير محدد', size: '100ml', price: 45, stock: 10 },
    ],
  },
  {
    storeKey: 'perfume',
    category: 'عطور',
    name: 'عطر نسائي فرنسي',
    description: 'عطر نسائي بلمسة فرنسية أنيقة برائحة زهرية جذابة.',
    variants: [
      { color: 'غير محدد', size: '50ml', price: 35, stock: 15 },
      { color: 'غير محدد', size: '100ml', price: 50, stock: 8 },
    ],
  },
  {
    storeKey: 'perfume',
    category: 'مستحضرات تجميل',
    name: 'أحمر شفاه مطفي',
    description: 'أحمر شفاه بتركيبة مطفية طويلة الثبات بألوان متعددة.',
    variants: [
      { color: 'أحمر', size: 'مقاس واحد', price: 8, stock: 40 },
      { color: 'وردي فاتح', size: 'مقاس واحد', price: 8, stock: 30 },
      { color: 'عنابي', size: 'مقاس واحد', price: 9, stock: 25 },
    ],
  },
];

// عناوين توصيل واقعية في حلب، عنوان واحد افتراضي لكل مستخدم
const addressesData = [
  { label: 'المنزل', address: 'شارع القصر الحديدي، حي الفرقان، حلب' },
  { label: 'المنزل', address: 'شارع بارون، حي العزيزية، حلب' },
  { label: 'العمل', address: 'شارع النيل، حي الشهباء، حلب' },
  { label: 'المنزل', address: 'شارع الفردوس، حي الميدان، حلب' },
  { label: 'المنزل', address: 'شارع سيف الدولة، حلب' },
];

// =============================================================================
// السكربت الرئيسي
// =============================================================================

async function seed() {
  console.log('🚀 بدء تشغيل سكربت البيانات الوهمية لمشروع Beep Beep...');
  console.log(`   قاعدة البيانات المستهدفة: ${process.env.DB_NAME || '(غير محددة في .env)'}`);
  console.log('');

  try {
    // -------------------------------------------------------------------
    // 1) تفريغ الجداول القديمة (لجعل السكربت قابلاً لإعادة التشغيل)
    // -------------------------------------------------------------------
    console.log('🧹 [1/9] تفريغ الجداول القديمة...');
    await pool.query('SET FOREIGN_KEY_CHECKS = 0');
    await truncateTable('cart_items');
    await truncateTable('carts');
    await truncateTable('favorites');
    await truncateTable('product_variants');
    await truncateTable('product_images');
    await truncateTable('products');
    await truncateTable('categories');
    await truncateTable('stores');
    await truncateTable('addresses');
    await truncateTable('users');
    await pool.query('SET FOREIGN_KEY_CHECKS = 1');
    console.log('');

    // -------------------------------------------------------------------
    // 2) المستخدمون
    // -------------------------------------------------------------------
    console.log('👤 [2/9] إضافة المستخدمين...');
    const passwordHash = await bcrypt.hash(SEED_PASSWORD, BCRYPT_ROUNDS);
    const userIds = [];
    const userIdsByKey = {}; // key -> id (Store Ownership feature: lets storesData below reference an owner)

    for (const u of usersData) {
      const now = new Date();
      const role = u.role || 'customer';
      const id = await insertRow('users', {
        name: u.name,
        phone: u.phone,
        email: u.email,
        password: passwordHash,
        role,
        created_at: now,
        updated_at: now,
      });
      userIds.push(id);
      userIdsByKey[u.key] = id;
      console.log(`   ✅ ${u.name} (id=${id}, email=${u.email}, role=${role})`);
    }
    console.log(`   ✔️  تم إضافة ${userIds.length} مستخدمين. كلمة المرور للجميع: "${SEED_PASSWORD}"`);
    console.log('');

    // -------------------------------------------------------------------
    // 3) المتاجر
    // -------------------------------------------------------------------
    console.log('🏬 [3/9] إضافة المتاجر...');
    const storeIds = {}; // key -> id

    for (const s of storesData) {
      const now = new Date();
      // ownerId: يُترك null إن لم يُحدَّد ownerKey (متجر بلا مالك حتى الآن).
      // إن كان عمود owner_id غير موجود بعد (لم تُطبَّق الهجرة 002)، فإن
      // insertRow ستتجاهله تلقائياً (نفس آلية التوافق المستخدمة أعلاه).
      const ownerId = s.ownerKey ? userIdsByKey[s.ownerKey] : null;
      // ندرج أولاً للحصول على id حقيقي، ثم نحدّث روابط الصور بناءً عليه
      const id = await insertRow('stores', {
        name: s.name,
        description: s.description,
        phone: s.phone,
        address: s.address,
        logo: `https://picsum.photos/seed/store${s.key}logo/200/200`,
        cover_image: `https://picsum.photos/seed/store${s.key}/400/200`,
        status: s.status,
        owner_id: ownerId,
        created_at: now,
        updated_at: now,
      });
      storeIds[s.key] = id;
      console.log(`   ✅ ${s.name} (id=${id}, status=${s.status}, owner=${s.ownerKey || 'none'})`);
    }
    console.log(`   ✔️  تم إضافة ${storesData.length} متاجر.`);
    console.log('');

    // -------------------------------------------------------------------
    // 4) التصنيفات
    // -------------------------------------------------------------------
    console.log('🏷️  [4/9] إضافة التصنيفات...');
    const categoryIds = {}; // name -> id

    for (const name of categoriesData) {
      const now = new Date();
      const id = await insertRow('categories', {
        name,
        parent_id: null, // سيُتجاهل تلقائياً إن لم يكن العمود موجوداً في الجدول
        created_at: now,
        updated_at: now,
      });
      categoryIds[name] = id;
      console.log(`   ✅ ${name} (id=${id})`);
    }
    console.log(`   ✔️  تم إضافة ${categoriesData.length} تصنيفات.`);
    console.log('');

    // -------------------------------------------------------------------
    // 5) المنتجات + الصور + المتغيرات
    // -------------------------------------------------------------------
    console.log('📦 [5/9] إضافة المنتجات (مع الصور والمتغيرات)...');
    const productRecords = []; // { id, name, storePhone, variants: [{id, price}] }
    let totalImages = 0;
    let totalVariants = 0;

    for (const p of productsData) {
      const storeId = storeIds[p.storeKey];
      const categoryId = categoryIds[p.category];

      if (!storeId || !categoryId) {
        throw new Error(
          `تعذر ربط المنتج "${p.name}": متجر أو تصنيف غير موجود (storeKey=${p.storeKey}, category=${p.category})`
        );
      }

      const now = new Date();
      const productId = await insertRow('products', {
        name: p.name,
        description: p.description,
        store_id: storeId,
        category_id: categoryId,
        created_at: now,
        updated_at: now,
      });

      // ---- الصور (2-3 صور، واحدة رئيسية) ----
      const numImages = 2 + (productId % 2); // يعطي 2 أو 3 صور بشكل متنوع
      for (let i = 1; i <= numImages; i++) {
        const isPrimary = i === 1;
        const imagePath = isPrimary
          ? `https://picsum.photos/seed/product${productId}/300/300?random=1`
          : `https://picsum.photos/seed/product${productId}/300/300?random=${i}`;

        await insertRow('product_images', {
          product_id: productId,
          image_path: imagePath,
          is_primary: isPrimary ? 1 : 0, // سيُتجاهل تلقائياً إن لم يكن العمود موجوداً
          created_at: now,
          updated_at: now,
        });
        totalImages++;
      }

      // ---- المتغيرات (ألوان/مقاسات/أسعار/مخزون) ----
      const variantIds = [];
      for (const v of p.variants) {
        const variantId = await insertRow('product_variants', {
          product_id: productId,
          color: v.color,
          size: v.size,
          price: v.price,
          stock: v.stock,
          created_at: now,
          updated_at: now,
        });
        variantIds.push({ id: variantId, price: v.price });
        totalVariants++;
      }

      productRecords.push({
        id: productId,
        name: p.name,
        storeId, // مضاف (ميزة ملكية المتاجر/سلة المتجر الواحد): يلزم لاشتقاق carts.store_id عند تعبئة سلال التسوق أدناه
        variants: variantIds,
      });

      console.log(
        `   ✅ ${p.name} (id=${productId}, صور=${numImages}, متغيرات=${p.variants.length})`
      );
    }
    console.log(
      `   ✔️  تم إضافة ${productRecords.length} منتجات، ${totalImages} صورة، ${totalVariants} متغيراً.`
    );
    console.log('');

    // -------------------------------------------------------------------
    // 6) العناوين (عنوان واحد افتراضي لكل مستخدم)
    // -------------------------------------------------------------------
    console.log('📍 [6/9] إضافة العناوين...');
    for (let i = 0; i < userIds.length; i++) {
      const now = new Date();
      const u = usersData[i];
      const a = addressesData[i];
      const id = await insertRow('addresses', {
        user_id: userIds[i],
        label: a.label,
        recipient_name: u.name,
        phone: u.phone,
        address: a.address,
        is_default: 1,
        created_at: now,
        updated_at: now,
      });
      console.log(`   ✅ عنوان لـ ${u.name} (id=${id})`);
    }
    console.log(`   ✔️  تم إضافة ${userIds.length} عناوين.`);
    console.log('');

    // -------------------------------------------------------------------
    // 7) المفضلة (لبعض المستخدمين)
    // -------------------------------------------------------------------
    console.log('❤️  [7/9] إضافة المنتجات المفضلة...');
    const favoritesPlan = [
      { userIndex: 0, productIndices: [0, 5, 8] },
      { userIndex: 1, productIndices: [3, 9] },
      { userIndex: 2, productIndices: [1, 6, 12] },
    ];

    let favoritesCount = 0;
    for (const plan of favoritesPlan) {
      const userId = userIds[plan.userIndex];
      for (const productIndex of plan.productIndices) {
        const product = productRecords[productIndex];
        const now = new Date();
        await insertRow('favorites', {
          user_id: userId,
          product_id: product.id,
          created_at: now,
        });
        favoritesCount++;
      }
      console.log(
        `   ✅ ${usersData[plan.userIndex].name}: ${plan.productIndices.length} منتجات مفضلة`
      );
    }
    console.log(`   ✔️  تم إضافة ${favoritesCount} عناصر مفضلة.`);
    console.log('');

    // -------------------------------------------------------------------
    // 8) سلة التسوق (لبعض المستخدمين)
    // -------------------------------------------------------------------
    // ملاحظة (ميزة قاعدة "متجر واحد لكل سلة"): كل سلة أدناه يجب أن تحتوي على
    // عناصر من متجر واحد فقط، لتبقى بيانات العرض التوضيحي متوافقة مع القاعدة
    // التي يفرضها الباكند الآن (cartService لن يقبل خلاف ذلك عبر الـ API على
    // أي حال، لكن هذا السكربت يدرج مباشرة في قاعدة البيانات دون المرور بالـ
    // API، لذا يجب الحرص يدوياً هنا).
    console.log('🛒 [8/9] إضافة سلال التسوق...');
    const cartsPlan = [
      // كلا المنتجين (index 2 و 0) من متجر الأزياء الحديثة (fashion, store_id=1).
      { userIndex: 0, items: [{ productIndex: 2, variantIndex: 0, quantity: 1 }, { productIndex: 0, variantIndex: 0, quantity: 2 }] },
      { userIndex: 3, items: [{ productIndex: 6, variantIndex: 1, quantity: 1 }] },
    ];

    let cartItemsCount = 0;
    for (const plan of cartsPlan) {
      const userId = userIds[plan.userIndex];
      const now = new Date();
      // كل عناصر الخطة من نفس المتجر (بحسب التعليق أعلاه)، فنشتق store_id
      // من أول عنصر فقط. إن كان عمود carts.store_id غير موجود بعد (لم تُطبَّق
      // الهجرة 002)، ستتجاهله insertRow تلقائياً كما هو الحال مع owner_id.
      const firstProduct = productRecords[plan.items[0].productIndex];
      const cartId = await insertRow('carts', {
        user_id: userId,
        store_id: firstProduct.storeId,
        created_at: now,
        updated_at: now,
      });

      for (const item of plan.items) {
        const product = productRecords[item.productIndex];
        const variant = product.variants[item.variantIndex];
        const itemNow = new Date();
        await insertRow('cart_items', {
          cart_id: cartId,
          variant_id: variant.id,
          quantity: item.quantity,
          price: variant.price,
          created_at: itemNow,
          updated_at: itemNow,
        });
        cartItemsCount++;
      }

      console.log(
        `   ✅ سلة لـ ${usersData[plan.userIndex].name} (cart_id=${cartId}, عناصر=${plan.items.length})`
      );
    }
    console.log(`   ✔️  تم إضافة ${cartsPlan.length} سلال تسوق بإجمالي ${cartItemsCount} عناصر.`);
    console.log('');

    // -------------------------------------------------------------------
    // 9) ملخص نهائي
    // -------------------------------------------------------------------
    console.log('🎉 [9/9] اكتمل تعبئة البيانات الوهمية بنجاح!');
    console.log('');
    console.log('====================== ملخص النتائج ======================');
    console.log(`   👤 مستخدمون:        ${userIds.length}`);
    console.log(`   🏬 متاجر:           ${storesData.length}`);
    console.log(`   🏷️  تصنيفات:         ${categoriesData.length}`);
    console.log(`   📦 منتجات:          ${productRecords.length}`);
    console.log(`   🖼️  صور منتجات:      ${totalImages}`);
    console.log(`   🎨 متغيرات منتجات:  ${totalVariants}`);
    console.log(`   📍 عناوين:          ${userIds.length}`);
    console.log(`   ❤️  عناصر مفضلة:     ${favoritesCount}`);
    console.log(`   🛒 سلال تسوق:       ${cartsPlan.length} (${cartItemsCount} عنصراً)`);
    console.log('============================================================');
    console.log('');
    console.log(`🔑 يمكنك تسجيل الدخول بأي من بريد المستخدمين أعلاه وكلمة المرور: "${SEED_PASSWORD}"`);
  } catch (error) {
    console.error('');
    console.error('❌ حدث خطأ أثناء تعبئة البيانات الوهمية:');
    console.error(`   ${error.message}`);
    if (error.sqlMessage) {
      console.error(`   SQL: ${error.sqlMessage}`);
    }
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
}

seed();
