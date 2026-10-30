'use client';

import { useEffect, useState } from 'react';

interface PendingPayment {
  id: string;
  amount: string;
  currency: string;
  proofImageUrl: string | null;
  customerReference: string | null;
  createdAt: string;
  order: {
    orderNumber: string;
    user: {
      firstName: string;
      lastName: string;
      phone: string | null;
    };
  };
}

export default function PaymentsVerificationPage() {
  const [payments, setPayments] = useState<PendingPayment[]>([]);
  const [loading, setLoading] = useState(true);
  const [processing, setProcessing] = useState<string | null>(null);

  const fetchPending = async () => {
    try {
      const res = await fetch('/api/payments/pending-verification', {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('adminToken')}`,
        },
      });
      const data = await res.json();
      setPayments(data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPending();
  }, []);

  const handleVerify = async (paymentId: string, approved: boolean) => {
    const notes = approved
      ? undefined
      : prompt('Motivo del rechazo (opcional):') || undefined;

    setProcessing(paymentId);
    try {
      await fetch(`/api/payments/verify/${paymentId}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${localStorage.getItem('adminToken')}`,
        },
        body: JSON.stringify({ approved, notes }),
      });
      await fetchPending();
    } catch (err) {
      alert('Error al procesar');
    } finally {
      setProcessing(null);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <p>Cargando pagos pendientes...</p>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <h1 className="text-2xl font-bold mb-6">
        Verificación de pagos Transfermóvil
      </h1>

      {payments.length === 0 ? (
        <div className="text-center py-20 text-gray-500">
          No hay pagos pendientes de verificación
        </div>
      ) : (
        <div className="space-y-6">
          {payments.map((p) => (
            <div
              key={p.id}
              className="border rounded-xl p-6 bg-white shadow-sm"
            >
              <div className="flex justify-between items-start mb-4">
                <div>
                  <p className="font-semibold text-lg">
                    Pedido {p.order.orderNumber}
                  </p>
                  <p className="text-sm text-gray-600">
                    {p.order.user.firstName} {p.order.user.lastName}
                    {p.order.user.phone && ` · ${p.order.user.phone}`}
                  </p>
                  <p className="text-sm text-gray-500 mt-1">
                    {new Date(p.createdAt).toLocaleString('es-CU')}
                  </p>
                </div>
                <div className="text-right">
                  <p className="text-2xl font-bold text-blue-600">
                    {p.amount} {p.currency}
                  </p>
                  {p.customerReference && (
                    <p className="text-sm text-gray-500">
                      Ref: {p.customerReference}
                    </p>
                  )}
                </div>
              </div>

              {p.proofImageUrl && (
                <div className="mb-4">
                  <p className="text-sm font-medium mb-2">Comprobante:</p>
                  <a
                    href={p.proofImageUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <img
                      src={p.proofImageUrl}
                      alt="Comprobante"
                      className="max-h-64 rounded-lg border"
                    />
                  </a>
                </div>
              )}

              <div className="flex gap-3">
                <button
                  onClick={() => handleVerify(p.id, true)}
                  disabled={processing === p.id}
                  className="px-5 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
                >
                  {processing === p.id ? 'Procesando...' : 'Aprobar'}
                </button>
                <button
                  onClick={() => handleVerify(p.id, false)}
                  disabled={processing === p.id}
                  className="px-5 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50"
                >
                  Rechazar
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
