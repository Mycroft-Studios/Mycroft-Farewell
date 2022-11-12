import { useSetInvoiceList } from '../atoms/bank-atoms';
import { useCallback } from 'react';
import { IInvoice } from '../types/bank';

interface UseBankActionsValue {
  newInvoice: (invoice: IInvoice) => void;
  declineLocalInvoice: (invoiceId: number) => void;
}

export const useBankActions = (): UseBankActionsValue => {
  const setInvoice = useSetInvoiceList();

  const newInvoice = useCallback(
    (invoice: IInvoice) => {
      setInvoice((curInvoices) => {
        return [invoice, ...curInvoices];
      });
    },
    [setInvoice],
  );

  const declineLocalInvoice = useCallback(
    (invoiceId: number) => {
      setInvoice((curInvoices) => [...curInvoices].filter((invoice) => invoice.id !== invoiceId));
    },
    [setInvoice],
  );

  return { newInvoice, declineLocalInvoice };
};
