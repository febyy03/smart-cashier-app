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
        // Appetizers
        \App\Models\Product::create([
            'name' => 'French Fries',
            'price' => 25000,
            'stock' => 100,
            'unit' => 'pcs',
            'category_id' => 1,
        ]);

        \App\Models\Product::create([
            'name' => 'Chicken Wings',
            'price' => 35000,
            'stock' => 80,
            'unit' => 'pcs',
            'category_id' => 1,
        ]);

        \App\Models\Product::create([
            'name' => 'Mozzarella Sticks',
            'price' => 28000,
            'stock' => 60,
            'unit' => 'pcs',
            'category_id' => 1,
        ]);

        \App\Models\Product::create([
            'name' => 'Onion Rings',
            'price' => 22000,
            'stock' => 70,
            'unit' => 'pcs',
            'category_id' => 1,
        ]);

        // Main Courses
        \App\Models\Product::create([
            'name' => 'Grilled Salmon',
            'price' => 85000,
            'stock' => 25,
            'unit' => 'pcs',
            'category_id' => 2,
        ]);

        \App\Models\Product::create([
            'name' => 'Beef Steak',
            'price' => 95000,
            'stock' => 20,
            'unit' => 'pcs',
            'category_id' => 2,
        ]);

        \App\Models\Product::create([
            'name' => 'Chicken Parmesan',
            'price' => 65000,
            'stock' => 30,
            'unit' => 'pcs',
            'category_id' => 2,
        ]);

        \App\Models\Product::create([
            'name' => 'Lamb Chops',
            'price' => 105000,
            'stock' => 15,
            'unit' => 'pcs',
            'category_id' => 2,
        ]);

        // Pasta & Noodles
        \App\Models\Product::create([
            'name' => 'Spaghetti Carbonara',
            'price' => 55000,
            'stock' => 40,
            'unit' => 'pcs',
            'category_id' => 3,
        ]);

        \App\Models\Product::create([
            'name' => 'Fettuccine Alfredo',
            'price' => 52000,
            'stock' => 35,
            'unit' => 'pcs',
            'category_id' => 3,
        ]);

        \App\Models\Product::create([
            'name' => 'Penne Arrabbiata',
            'price' => 48000,
            'stock' => 45,
            'unit' => 'pcs',
            'category_id' => 3,
        ]);

        // Rice Dishes
        \App\Models\Product::create([
            'name' => 'Chicken Fried Rice',
            'price' => 42000,
            'stock' => 50,
            'unit' => 'pcs',
            'category_id' => 4,
        ]);

        \App\Models\Product::create([
            'name' => 'Beef Fried Rice',
            'price' => 45000,
            'stock' => 45,
            'unit' => 'pcs',
            'category_id' => 4,
        ]);

        // Sandwiches
        \App\Models\Product::create([
            'name' => 'Club Sandwich',
            'price' => 38000,
            'stock' => 40,
            'unit' => 'pcs',
            'category_id' => 5,
        ]);

        \App\Models\Product::create([
            'name' => 'BLT Sandwich',
            'price' => 32000,
            'stock' => 35,
            'unit' => 'pcs',
            'category_id' => 5,
        ]);

        // Burgers
        \App\Models\Product::create([
            'name' => 'Classic Burger',
            'price' => 45000,
            'stock' => 60,
            'unit' => 'pcs',
            'category_id' => 6,
        ]);

        \App\Models\Product::create([
            'name' => 'Cheese Burger',
            'price' => 48000,
            'stock' => 55,
            'unit' => 'pcs',
            'category_id' => 6,
        ]);

        \App\Models\Product::create([
            'name' => 'Bacon Burger',
            'price' => 52000,
            'stock' => 50,
            'unit' => 'pcs',
            'category_id' => 6,
        ]);

        // Pizza
        \App\Models\Product::create([
            'name' => 'Margherita Pizza',
            'price' => 65000,
            'stock' => 30,
            'unit' => 'pcs',
            'category_id' => 7,
        ]);

        \App\Models\Product::create([
            'name' => 'Pepperoni Pizza',
            'price' => 75000,
            'stock' => 25,
            'unit' => 'pcs',
            'category_id' => 7,
        ]);

        // Salads
        \App\Models\Product::create([
            'name' => 'Caesar Salad',
            'price' => 35000,
            'stock' => 40,
            'unit' => 'pcs',
            'category_id' => 8,
        ]);

        \App\Models\Product::create([
            'name' => 'Greek Salad',
            'price' => 38000,
            'stock' => 35,
            'unit' => 'pcs',
            'category_id' => 8,
        ]);

        // Coffee
        \App\Models\Product::create([
            'name' => 'Espresso',
            'price' => 18000,
            'stock' => 100,
            'unit' => 'cup',
            'category_id' => 9,
        ]);

        \App\Models\Product::create([
            'name' => 'Cappuccino',
            'price' => 25000,
            'stock' => 80,
            'unit' => 'cup',
            'category_id' => 9,
        ]);

        \App\Models\Product::create([
            'name' => 'Latte',
            'price' => 28000,
            'stock' => 75,
            'unit' => 'cup',
            'category_id' => 9,
        ]);

        \App\Models\Product::create([
            'name' => 'Americano',
            'price' => 20000,
            'stock' => 90,
            'unit' => 'cup',
            'category_id' => 9,
        ]);

        // Tea
        \App\Models\Product::create([
            'name' => 'Green Tea',
            'price' => 15000,
            'stock' => 60,
            'unit' => 'cup',
            'category_id' => 10,
        ]);

        \App\Models\Product::create([
            'name' => 'Black Tea',
            'price' => 14000,
            'stock' => 65,
            'unit' => 'cup',
            'category_id' => 10,
        ]);

        // Hot Beverages
        \App\Models\Product::create([
            'name' => 'Hot Chocolate',
            'price' => 22000,
            'stock' => 50,
            'unit' => 'cup',
            'category_id' => 11,
        ]);

        \App\Models\Product::create([
            'name' => 'Chamomile Tea',
            'price' => 16000,
            'stock' => 45,
            'unit' => 'cup',
            'category_id' => 11,
        ]);

        // Cold Beverages
        \App\Models\Product::create([
            'name' => 'Iced Coffee',
            'price' => 20000,
            'stock' => 70,
            'unit' => 'cup',
            'category_id' => 12,
        ]);

        \App\Models\Product::create([
            'name' => 'Lemonade',
            'price' => 18000,
            'stock' => 80,
            'unit' => 'cup',
            'category_id' => 12,
        ]);

        \App\Models\Product::create([
            'name' => 'Coca Cola',
            'price' => 12000,
            'stock' => 100,
            'unit' => 'btl',
            'category_id' => 12,
        ]);

        // Smoothies
        \App\Models\Product::create([
            'name' => 'Strawberry Smoothie',
            'price' => 28000,
            'stock' => 40,
            'unit' => 'cup',
            'category_id' => 13,
        ]);

        \App\Models\Product::create([
            'name' => 'Mango Smoothie',
            'price' => 28000,
            'stock' => 40,
            'unit' => 'cup',
            'category_id' => 13,
        ]);

        // Fresh Juices
        \App\Models\Product::create([
            'name' => 'Orange Juice',
            'price' => 22000,
            'stock' => 50,
            'unit' => 'cup',
            'category_id' => 14,
        ]);

        \App\Models\Product::create([
            'name' => 'Apple Juice',
            'price' => 22000,
            'stock' => 50,
            'unit' => 'cup',
            'category_id' => 14,
        ]);

        // Desserts
        \App\Models\Product::create([
            'name' => 'Chocolate Cake',
            'price' => 35000,
            'stock' => 25,
            'unit' => 'pcs',
            'category_id' => 15,
        ]);

        \App\Models\Product::create([
            'name' => 'Cheesecake',
            'price' => 38000,
            'stock' => 20,
            'unit' => 'pcs',
            'category_id' => 15,
        ]);

        \App\Models\Product::create([
            'name' => 'Tiramisu',
            'price' => 42000,
            'stock' => 18,
            'unit' => 'pcs',
            'category_id' => 15,
        ]);

        // Ice Cream
        \App\Models\Product::create([
            'name' => 'Vanilla Ice Cream',
            'price' => 18000,
            'stock' => 60,
            'unit' => 'cup',
            'category_id' => 16,
        ]);

        \App\Models\Product::create([
            'name' => 'Chocolate Ice Cream',
            'price' => 18000,
            'stock' => 60,
            'unit' => 'cup',
            'category_id' => 16,
        ]);

        // Cakes
        \App\Models\Product::create([
            'name' => 'Red Velvet Cake',
            'price' => 45000,
            'stock' => 15,
            'unit' => 'pcs',
            'category_id' => 17,
        ]);

        \App\Models\Product::create([
            'name' => 'Carrot Cake',
            'price' => 40000,
            'stock' => 12,
            'unit' => 'pcs',
            'category_id' => 17,
        ]);

        // Snacks
        \App\Models\Product::create([
            'name' => 'Potato Chips',
            'price' => 15000,
            'stock' => 80,
            'unit' => 'bag',
            'category_id' => 18,
        ]);

        \App\Models\Product::create([
            'name' => 'Nachos',
            'price' => 25000,
            'stock' => 40,
            'unit' => 'pcs',
            'category_id' => 18,
        ]);
    }
}
