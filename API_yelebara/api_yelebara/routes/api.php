<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;


Route::post('/register', [AuthController::class, 'register']);   // Client ou Presseur
Route::post('/login', [AuthController::class, 'login']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);



Route::middleware('auth:sanctum')->group(function () {

    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::prefix('client')->group(function () {
        Route::get('/profile', [AuthController::class, 'clientProfile']);
        Route::post('/profile/update', [AuthController::class, 'updateClientProfile']);
    });

    Route::prefix('presseur')->group(function () {
        Route::get('/profile', [AuthController::class, 'presseurProfile']);
        Route::post('/profile/update', [AuthController::class, 'updatePresseurProfile']);
        Route::post('/zones', [AuthController::class, 'assignZones']); // Assigner zones
    });

    Route::prefix('admin')->middleware('admin')->group(function () {
        Route::get('/presseurs', [AuthController::class, 'listPresseurs']);
        Route::post('/presseur/verify/{id}', [AuthController::class, 'verifyPresseur']);
        Route::post('/presseur/reject/{id}', [AuthController::class, 'rejectPresseur']);
    });

});
