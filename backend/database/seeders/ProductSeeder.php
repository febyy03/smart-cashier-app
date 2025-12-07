<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Appetizers - Only products with images
        \App\Models\Product::create([
            'name' => 'French Fries',
            'price' => 25000,
            'stock' => 100,
            'unit' => 'pcs',
            'category_id' => 1,
            'image_url' => 'assets/images/french fries.jpeg',
        ]);

        \App\Models\Product::create([
            'name' => 'Chicken Wings',
            'price' => 35000,
            'stock' => 80,
            'unit' => 'pcs',
            'category_id' => 1,
            'image_url' => 'assets/images/chiken wings.jpeg',
        ]);

        \App\Models\Product::create([
            'name' => 'Mozzarella Sticks',
            'price' => 28000,
            'stock' => 60,
            'unit' => 'pcs',
            'category_id' => 1,
            'image_url' => 'assets/images/mozzarella sticks.jpeg',
        ]);

        \App\Models\Product::create([
            'name' => 'Onion Rings',
            'price' => 22000,
            'stock' => 70,
            'unit' => 'pcs',
            'category_id' => 1,
            'image_url' => 'assets/images/onion rings.jpeg',
        ]);

        // Main Courses - Only products with images
        \App\Models\Product::create([
            'name' => 'Grilled Salmon',
            'price' => 85000,
            'stock' => 25,
            'unit' => 'pcs',
            'category_id' => 2,
            'image_url' => 'assets/images/grilled salmon.jpeg',
        ]);

        \App\Models\Product::create([
            'name' => 'Beef Steak',
            'price' => 95000,
            'stock' => 20,
            'unit' => 'pcs',
            'category_id' => 2,
            'image_url' => 'assets/images/beef steak.jpeg',
        ]);

        \App\Models\Product::create([
            'name' => 'Chicken Parmesan',
            'price' => 65000,
            'stock' => 30,
            'unit' => 'pcs',
            'category_id' => 2,
            'image_url' => 'assets/images/chicken parmesan.jpeg',
        ]);

        \App\Models\Product::create([
            'name' => 'Lamb Chops',
            'price' => 105000,
            'stock' => 15,
            'unit' => 'pcs',
            'category_id' => 2,
            'image_url' => 'assets/images/lamb chops.jpeg',
        ]);

        // Pasta & Noodles - Only products with images
        \App\Models\Product::create([
            'name' => 'Spaghetti Carbonara',
            'price' => 55000,
            'stock' => 40,
            'unit' => 'pcs',
            'category_id' => 3,
            'image_url' => 'assets/images/spaghetti carbonara.jpeg',
        ]);

        \App\Models\Product::create([
            'name' => 'Fettuccine Alfredo',
            'price' => 52000,
            'stock' => 35,
            'unit' => 'pcs',
            'category_id' => 3,
            'image_url' => 'assets/images/fettuccine alfredo.jpeg',
        ]);

        // Indonesian Rice Dishes (Nasi) - Only with images
        \App\Models\Product::create([
            'name' => 'Nasi Goreng',
            'price' => 25000,
            'stock' => 50,
            'unit' => 'pcs',
            'category_id' => 19,
            'image_url' => 'assets/images/nasi goreng.jpeg',
        ]);

        // Indonesian Chicken Dishes (Ayam) - Only with images
        \App\Models\Product::create([
            'name' => 'Ayam Goreng',
            'price' => 30000,
            'stock' => 60,
            'unit' => 'pcs',
            'category_id' => 20,
            'image_url' => 'assets/images/ayam utuh.jpeg',
        ]);

        \App\Models\Product::create([
            'name' => 'Ayam Bakar',
            'price' => 35000,
            'stock' => 50,
            'unit' => 'pcs',
            'category_id' => 20,
            'image_url' => 'assets/images/lalapan ayam.jpeg',
        ]);

        // Indonesian Meatballs & Noodles (Bakso & Mie) - Only with images
        \App\Models\Product::create([
            'name' => 'Mie Goreng',
            'price' => 20000,
            'stock' => 75,
            'unit' => 'bowl',
            'category_id' => 22,
            'image_url' => 'assets/images/mie goreng.jpeg',
        ]);

        // Traditional Indonesian Beverages (Minuman Tradisional) - Only with images
        \App\Models\Product::create([
            'name' => 'Es Teh',
            'price' => 8000,
            'stock' => 150,
            'unit' => 'cup',
            'category_id' => 24,
            'image_url' => 'assets/images/es teh.jpeg',
        ]);

        \App\Models\Product::create([
            'name' => 'Es Jeruk',
            'price' => 10000,
            'stock' => 120,
            'unit' => 'cup',
            'category_id' => 24,
            'image_url' => 'assets/images/es jeruk segar.jpeg',
        ]);

        // Indonesian Fruit Juices (Jus Buah) - Only with images
        \App\Models\Product::create([
            'name' => 'Jus Mangga',
            'price' => 16000,
            'stock' => 80,
            'unit' => 'cup',
            'category_id' => 25,
            'image_url' => 'assets/images/jus mangga.jpeg',
        ]);

        \App\Models\Product::create([
            'name' => 'Jus Jambu',
            'price' => 15000,
            'stock' => 75,
            'unit' => 'cup',
            'category_id' => 25,
            'image_url' => 'assets/images/jus jambu.jpeg',
        ]);
    }
}
