<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TransactionController extends Controller
{
    public function index(Request $request)
    {
        $transactions = Transaction::with('user')->where('user_id', $request->user()->id)->get();
        return response()->json($transactions->map(function ($transaction) {
            return [
                'id' => $transaction->id,
                'user_id' => $transaction->user_id,
                'total' => $transaction->total,
                'items' => $transaction->items,
                'transaction_date' => $transaction->transaction_date,
                'payment_method' => $transaction->payment_method,
                'tax' => $transaction->tax,
                'discount' => $transaction->discount,
                'user' => $transaction->user,
            ];
        }));
    }

    public function store(Request $request)
    {
        $request->validate([
            'items' => 'required|array',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'payment_method' => 'required|in:cash,digital',
            'tax' => 'numeric|min:0',
            'discount' => 'numeric|min:0',
        ]);

        $subtotal = 0;
        $items = [];
        $tax = $request->tax ?? 0;
        $discount = $request->discount ?? 0;

        $transaction = DB::transaction(function () use ($request, &$subtotal, &$items, $tax, $discount) {
            foreach ($request->items as $item) {
                $product = Product::find($item['product_id']);
                if ($product->stock < $item['quantity']) {
                    throw new \Exception('Insufficient stock for ' . $product->name);
                }
                $product->decrement('stock', $item['quantity']);
                $itemTotal = $product->price * $item['quantity'];
                $subtotal += $itemTotal;
                $items[] = [
                    'product_id' => $product->id,
                    'name' => $product->name,
                    'price' => $product->price,
                    'quantity' => $item['quantity'],
                    'subtotal' => $itemTotal,
                ];
            }

            $total = $subtotal + $tax - $discount;

            return Transaction::create([
                'user_id' => $request->user()->id,
                'total' => $total,
                'items' => $items,
                'transaction_date' => now(),
                'payment_method' => $request->payment_method,
                'tax' => $tax,
                'discount' => $discount,
            ]);
        });

        return response()->json([
            'message' => 'Transaction created successfully',
            'transaction_id' => $transaction->id,
            'total' => $transaction->total
        ], 201);
    }

    public function show(Transaction $transaction)
    {
        if ($transaction->user_id !== request()->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        return response()->json($transaction);
    }
}
