<?php

namespace Database\Seeders;

use App\Models\Product;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class TransactionSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $user = User::first(); // Get the first user (admin)

        // Transaction 1: Nasi Goreng and Es Teh
        $nasiGoreng = Product::where('name', 'Nasi Goreng')->first();
        $esTeh = Product::where('name', 'Es Teh')->first();

        if ($nasiGoreng && $esTeh && $user) {
            $items1 = [
                [
                    'product_id' => $nasiGoreng->id,
                    'name' => $nasiGoreng->name,
                    'price' => $nasiGoreng->price,
                    'quantity' => 1,
                    'subtotal' => $nasiGoreng->price * 1,
                ],
                [
                    'product_id' => $esTeh->id,
                    'name' => $esTeh->name,
                    'price' => $esTeh->price,
                    'quantity' => 1,
                    'subtotal' => $esTeh->price * 1,
                ],
            ];

            Transaction::create([
                'user_id' => $user->id,
                'total' => array_sum(array_column($items1, 'subtotal')),
                'items' => $items1,
                'transaction_date' => now()->subDays(2),
            ]);

            // Reduce stock
            $nasiGoreng->decrement('stock', 1);
            $esTeh->decrement('stock', 1);
        }

        // Transaction 2: Ayam Goreng and Jus Alpukat
        $ayamGoreng = Product::where('name', 'Ayam Goreng')->first();
        $jusAlpukat = Product::where('name', 'Jus Alpukat')->first();

        if ($ayamGoreng && $jusAlpukat && $user) {
            $items2 = [
                [
                    'product_id' => $ayamGoreng->id,
                    'name' => $ayamGoreng->name,
                    'price' => $ayamGoreng->price,
                    'quantity' => 2,
                    'subtotal' => $ayamGoreng->price * 2,
                ],
                [
                    'product_id' => $jusAlpukat->id,
                    'name' => $jusAlpukat->name,
                    'price' => $jusAlpukat->price,
                    'quantity' => 1,
                    'subtotal' => $jusAlpukat->price * 1,
                ],
            ];

            Transaction::create([
                'user_id' => $user->id,
                'total' => array_sum(array_column($items2, 'subtotal')),
                'items' => $items2,
                'transaction_date' => now()->subDays(1),
            ]);

            // Reduce stock
            $ayamGoreng->decrement('stock', 2);
            $jusAlpukat->decrement('stock', 1);
        }

        // Transaction 3: Sate Ayam and Wedang Jahe
        $sateAyam = Product::where('name', 'Sate Ayam')->first();
        $wedangJahe = Product::where('name', 'Wedang Jahe')->first();

        if ($sateAyam && $wedangJahe && $user) {
            $items3 = [
                [
                    'product_id' => $sateAyam->id,
                    'name' => $sateAyam->name,
                    'price' => $sateAyam->price,
                    'quantity' => 1,
                    'subtotal' => $sateAyam->price * 1,
                ],
                [
                    'product_id' => $wedangJahe->id,
                    'name' => $wedangJahe->name,
                    'price' => $wedangJahe->price,
                    'quantity' => 2,
                    'subtotal' => $wedangJahe->price * 2,
                ],
            ];

            Transaction::create([
                'user_id' => $user->id,
                'total' => array_sum(array_column($items3, 'subtotal')),
                'items' => $items3,
                'transaction_date' => now()->subHours(5),
            ]);

            // Reduce stock
            $sateAyam->decrement('stock', 1);
            $wedangJahe->decrement('stock', 2);
        }

        // Transaction 4: Bakso and Es Jeruk
        $bakso = Product::where('name', 'Bakso')->first();
        $esJeruk = Product::where('name', 'Es Jeruk')->first();

        if ($bakso && $esJeruk && $user) {
            $items4 = [
                [
                    'product_id' => $bakso->id,
                    'name' => $bakso->name,
                    'price' => $bakso->price,
                    'quantity' => 1,
                    'subtotal' => $bakso->price * 1,
                ],
                [
                    'product_id' => $esJeruk->id,
                    'name' => $esJeruk->name,
                    'price' => $esJeruk->price,
                    'quantity' => 1,
                    'subtotal' => $esJeruk->price * 1,
                ],
            ];

            Transaction::create([
                'user_id' => $user->id,
                'total' => array_sum(array_column($items4, 'subtotal')),
                'items' => $items4,
                'transaction_date' => now()->subHours(2),
            ]);

            // Reduce stock
            $bakso->decrement('stock', 1);
            $esJeruk->decrement('stock', 1);
        }

        // Transaction 5: Mie Ayam and Kopi Tubruk
        $mieAyam = Product::where('name', 'Mie Ayam')->first();
        $kopiTubruk = Product::where('name', 'Kopi Tubruk')->first();

        if ($mieAyam && $kopiTubruk && $user) {
            $items5 = [
                [
                    'product_id' => $mieAyam->id,
                    'name' => $mieAyam->name,
                    'price' => $mieAyam->price,
                    'quantity' => 1,
                    'subtotal' => $mieAyam->price * 1,
                ],
                [
                    'product_id' => $kopiTubruk->id,
                    'name' => $kopiTubruk->name,
                    'price' => $kopiTubruk->price,
                    'quantity' => 1,
                    'subtotal' => $kopiTubruk->price * 1,
                ],
            ];

            Transaction::create([
                'user_id' => $user->id,
                'total' => array_sum(array_column($items5, 'subtotal')),
                'items' => $items5,
                'transaction_date' => now()->subHours(1),
            ]);

            // Reduce stock
            $mieAyam->decrement('stock', 1);
            $kopiTubruk->decrement('stock', 1);
        }
    }
}
