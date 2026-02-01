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

    // Routes admin
    Route::middleware('role:admin')->prefix('admin')->group(function () {
        Route::get('/dashboard', [AdminController::class, 'dashboard']);
        Route::get('/presseurs/pending', [AdminController::class, 'pendingPresseurs']);
        Route::post('/presseurs/{id}/validate', [AdminController::class, 'validatePresseur']);
        Route::post('/presseurs/{id}/reject', [AdminController::class, 'rejectPresseur']);
    });
});