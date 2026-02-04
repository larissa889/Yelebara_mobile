<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\ZoneController;

// Routes publiques
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/password/send-code', [AuthController::class, 'sendResetCode']);
Route::post('/password/reset', [AuthController::class, 'resetPassword']);
Route::get('/zones', [ZoneController::class, 'index']);

// Routes protégées
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/user/update', [AuthController::class, 'updateProfile']);

    // Routes Orders
    Route::get('/orders', [App\Http\Controllers\OrderController::class, 'index']);
    Route::post('/orders', [App\Http\Controllers\OrderController::class, 'store']);
    Route::get('/orders/{id}', [App\Http\Controllers\OrderController::class, 'show']);

    // Routes admin
    Route::middleware('role:admin')->prefix('admin')->group(function () {
        Route::get('/dashboard', [AdminController::class, 'dashboard']);
        Route::get('/presseurs/pending', [AdminController::class, 'pendingPresseurs']);
        Route::post('/presseurs/{id}/validate', [AdminController::class, 'validatePresseur']);
        Route::post('/presseurs/{id}/reject', [AdminController::class, 'rejectPresseur']);
    });
});