<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    protected $fillable = ['user_id', 'total', 'items', 'transaction_date', 'payment_method', 'tax', 'discount'];

    protected $casts = [
        'total' => 'decimal:2',
        'items' => 'array',
        'transaction_date' => 'datetime',
        'tax' => 'decimal:2',
        'discount' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
