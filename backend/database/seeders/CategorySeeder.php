<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        \App\Models\Category::create(['name' => 'Appetizers']);
        \App\Models\Category::create(['name' => 'Main Courses']);
        \App\Models\Category::create(['name' => 'Pasta & Noodles']);
        \App\Models\Category::create(['name' => 'Rice Dishes']);
        \App\Models\Category::create(['name' => 'Sandwiches']);
        \App\Models\Category::create(['name' => 'Burgers']);
        \App\Models\Category::create(['name' => 'Pizza']);
        \App\Models\Category::create(['name' => 'Salads']);
        \App\Models\Category::create(['name' => 'Coffee']);
        \App\Models\Category::create(['name' => 'Tea']);
        \App\Models\Category::create(['name' => 'Hot Beverages']);
        \App\Models\Category::create(['name' => 'Cold Beverages']);
        \App\Models\Category::create(['name' => 'Smoothies']);
        \App\Models\Category::create(['name' => 'Fresh Juices']);
        \App\Models\Category::create(['name' => 'Desserts']);
        \App\Models\Category::create(['name' => 'Ice Cream']);
        \App\Models\Category::create(['name' => 'Cakes']);
        \App\Models\Category::create(['name' => 'Snacks']);
    }
}
