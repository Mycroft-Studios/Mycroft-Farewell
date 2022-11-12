import { useCallback } from 'react';
import { useSnackbar } from '../snackbar/useSnackbar';
import { ServerPromiseResp } from '../types/common';
import fetchNui from '../utils/fetchNui';
import { BankTransferDTO, IInvoice } from '../types/bank'
import { useSetBankBalance } from '../atoms/bank-atoms';
import { useBankActions } from './useBankActions';

interface BankAPIValue {
  transferMoney: (data: BankTransferDTO) => Promise<void>;
  declineInvoice: (invoiceId: number) => Promise<void>;
  payInvoice: (invoice: IInvoice) => Promise<void>;
}

export const useBankAPI = (): BankAPIValue => {
  const { addAlert } = useSnackbar();
  const updateBalance = useSetBankBalance();
  const { declineLocalInvoice } = useBankActions();

  const transferMoney = useCallback(
    async ({ amount, toAccount, transferType }: BankTransferDTO) => {
      const resp = await fetchNui<ServerPromiseResp<number>>("npwd:qb-banking:transferMoney", {
        amount,
        toAccount,
        transferType
      });

      if (resp.status !== 'ok') {
        return addAlert({
          message: 'Failed to transfer money',
          type: 'error',
        });
      }

      if (!resp.data || typeof resp.data !== "number") {
        return addAlert({
          message: 'Money Transfered, issue with updating balance',
          type: 'warning',
        });
      }

      addAlert({
        message: 'Successfully transfered money',
        type: 'success',
      });
    },
    [addAlert],
  );

  const declineInvoice = useCallback(
    async (invoiceId: number) => {
      const resp = await fetchNui<ServerPromiseResp>("npwd:qb-banking:declineInvoice", invoiceId);

      if (resp.status !== 'ok') {
        return addAlert({
          message: 'Failed to decline invoice',
          type: 'error',
        });
      }

      declineLocalInvoice(invoiceId);

      addAlert({
        message: 'Successfully declined invoice',
        type: 'success',
      });
    },
    [addAlert, declineLocalInvoice],
  );

  const payInvoice = useCallback(
    async (invoice: IInvoice) => {
      const resp = await fetchNui<ServerPromiseResp<number>>("npwd:qb-banking:payInvoice", invoice);

      if (resp.status !== 'ok') {
        return addAlert({
          message: 'Failed to pay invoice',
          type: 'error',
        });
      }

      declineLocalInvoice(invoice.id);
      updateBalance(resp.data)

      addAlert({
        message: 'Successfully paid invoice',
        type: 'success',
      });
    },
    [addAlert, declineLocalInvoice],
  );

  return { transferMoney, declineInvoice, payInvoice };
};