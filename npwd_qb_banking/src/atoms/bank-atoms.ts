import { atom, selector, useRecoilValue, useSetRecoilState } from 'recoil';
import fetchNui from '../utils/fetchNui';
import { ServerPromiseResp } from '../types/common';
import { isEnvBrowser } from '../utils/misc';
import { IContacts, IInvoice } from '../types/bank';
import { MockContacts, MockInvoices } from '../utils/constants';

export const bankStates = {
  bankBalance: atom({
    key: 'bankBalance',
    default: selector<number>({
      key: 'defaultBankBalance',
      get: async () => {
        try {
          const resp = await fetchNui<ServerPromiseResp<number>>('npwd:qb-banking:getBalance');
          if (!resp.data) {
            console.log('no response data');
            return 0;
          }
          return resp.data;
        } catch (e) {
          if (isEnvBrowser()) {
            return 500;
          }
          console.error(e);
          return 0;
        }
      },
    }),
  }),
  accountNumber: atom({
    key: 'accountNumber',
    default: selector<string>({
      key: 'defaultAccountNumber',
      get: async () => {
        try {
          const resp = await fetchNui<ServerPromiseResp<string>>('npwd:qb-banking:getAccountNumber');
          if (!resp.data) {
            console.log('no response data');
            return "";
          }
          return resp.data;
        } catch (e) {
          if (isEnvBrowser()) {
            return "US09QBCore3036705542";
          }
          console.error(e);
          return "";
        }
      },
    }),
  }),
  contacts: atom({
    key: 'contacts',
    default: selector<IContacts[]>({
      key: 'defaultContacts',
      get: async () => {
        try {
          const resp = await fetchNui<ServerPromiseResp<IContacts[]>>('npwd:qb-banking:getContacts');
          if (!resp.data) {
            console.log('no response data');
            return [];
          }
          return resp.data;
        } catch (e) {
          if (isEnvBrowser()) {
            return MockContacts;
          }
          console.error(e);
          return [];
        }
      },
    }),
  }),
  invoiceList: atom({
    key: 'invoiceList',
    default: selector<IInvoice[]>({
      key: 'defaultInvoiceList',
      get: async () => {
        try {
        const resp = await fetchNui<ServerPromiseResp<IInvoice[]>>('npwd:qb-banking:getInvoices');
          if (!resp.data) {
            console.log('no response data');
            return [];
          }
          return resp.data;
        } catch (e) {
          if (isEnvBrowser()) {
            return MockInvoices;
          }
          console.error(e);
          return [];
        }
      },
    }),
  }),
};

export const useBankBalanceValue = () => useRecoilValue(bankStates.bankBalance);
export const useSetBankBalance = () => useSetRecoilState(bankStates.bankBalance)

export const useAccountNumberValue = () => useRecoilValue(bankStates.accountNumber);

export const useContactsValue = () => useRecoilValue(bankStates.contacts);

export const useInvoiceListValue = () => useRecoilValue(bankStates.invoiceList);
export const useSetInvoiceList = () => useSetRecoilState(bankStates.invoiceList)
