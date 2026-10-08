<?php

namespace App\Http\Controllers\Quran\Donation;

use App\Http\Controllers\Controller;
use App\Models\Quran\Donation\Donation;
use Illuminate\Support\Facades\DB;

class DonationController extends Controller
{
    public function index()
    {
        try {
            $status  = request('status');
            $perPage = in_array((int) request('per_page'), [10, 25, 50]) ? (int) request('per_page') : 10;
            $search  = request('search');

            $gateway = request('gateway');

            $query = Donation::query()
                ->latest('donations.created_at')
                ->select(
                    'donations.id',
                    'donations.email',
                    'donations.name',
                    'donations.category_id',
                    'donations.payment_method_id',
                    'donations.payment_gateway',
                    'donations.status',
                    'donations.currency',
                    'donations.created_at'
                )
                ->leftJoin('categories',       'donations.category_id',      '=', 'categories.id')
                ->leftJoin('payment_methods',  'donations.payment_method_id','=', 'payment_methods.id')
                ->with([
                    'paymentMethod',
                    'transaction' => function ($q) {
                        $q->select('id', 'donation_id', 'amount',
                            DB::raw("DATE_FORMAT(date, '%d %b %Y, %h:%i %p') as date"));
                    },
                    'category:id,name',
                ])
                ->when($status,  fn($q) => $q->where('donations.status', $status))
                ->when($gateway, fn($q) => $q->where('donations.payment_gateway', $gateway))
                ->when($search, function ($q) use ($search) {
                    $q->where(function ($inner) use ($search) {
                        $inner->where('donations.email',            'like', "%$search%")
                              ->orWhere('donations.name',           'like', "%$search%")
                              ->orWhere('categories.name',          'like', "%$search%")
                              ->orWhere('donations.payment_gateway','like', "%$search%")
                              ->orWhere('payment_methods.name',     'like', "%$search%");
                    });
                });

            $donations = $query->paginate($perPage);

            // Aggregate stats (unfiltered by status/search so cards always show totals)
            $stats = Donation::query()
                ->leftJoin('transactions', 'donations.id', '=', 'transactions.donation_id')
                ->selectRaw('
                    COUNT(donations.id)                                             as total,
                    SUM(CASE WHEN donations.status = "completed"  THEN 1 ELSE 0 END) as completed,
                    SUM(CASE WHEN donations.status = "pending"    THEN 1 ELSE 0 END) as pending,
                    SUM(CASE WHEN donations.status = "cancelled"  THEN 1 ELSE 0 END) as cancelled,
                    COALESCE(SUM(CASE WHEN donations.status = "completed" THEN transactions.amount ELSE 0 END), 0) as total_amount
                ')
                ->first();

            return response()->json([
                'data'  => $donations,
                'stats' => $stats,
            ]);

        } catch (\Exception $e) {
            return response()->json(['status' => false, 'message' => $e->getMessage()]);
        }
    }
}
