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
        \App\Models\Product::create([
            'name' => 'Nasi Goreng',
            'price' => 15000,
            'stock' => 50,
            'unit' => 'pcs',
            'category_id' => 1,
        ]);

        \App\Models\Product::create([
            'name' => 'Ayam Bakar',
            'price' => 20000,
            'stock' => 30,
            'unit' => 'pcs',
            'category_id' => 1,
        ]);

        \App\Models\Product::create([
            'name' => 'Coca Cola',
            'price' => 5000,
            'stock' => 100,
            'unit' => 'btl',
            'category_id' => 2,
        ]);

        \App\Models\Product::create([
            'name' => 'Sprite',
            'price' => 5000,
            'stock' => 80,
            'unit' => 'btl',
            'category_id' => 2,
        ]);

        \App\Models\Product::create([
            'name' => 'Keripik Kentang',
            'price' => 8000,
            'stock' => 60,
            'unit' => 'pcs',
            'category_id' => 3,
        ]);
    }
}
