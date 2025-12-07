<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\DashboardController;
use App\Http\Controllers\API\ProductController;
use App\Http\Controllers\API\TransactionController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);

    Route::apiResource('products', ProductController::class);
    Route::get('/categories', [ProductController::class, 'categoriesIndex']);
    Route::apiResource('transactions', TransactionController::class)->except(['update', 'destroy']);

    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::get('/recommendations', [DashboardController::class, 'recommendations']);
});