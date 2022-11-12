import { atom, selector, useRecoilState, useRecoilValue, useSetRecoilState } from 'recoil';
import { Mail } from '../types/mail';
import { MockMail } from '../utils/constants';
import { isEnvBrowser } from '../utils/misc';
import fetchNui from '../utils/fetchNui';
import { ServerPromiseResp } from '../types/common';

export const mailStates = {
  mailItems: atom({
    key: 'mailItem',
    default: selector<Mail[]>({
      key: 'defaultMailItems',
      get: async () => {
        try {
          const resp = await fetchNui<ServerPromiseResp<Mail[]>>('npwd:qb-mail:getMail');
          if (!resp.data) {
            console.log('no response data');
            return [];
          }
          return resp.data;
        } catch (e) {
          if (isEnvBrowser()) {
            return MockMail;
          }
          console.error(e);
          return [];
        }
      },
    }),
  }),
  selectedMail: atom<Partial<Mail> | null>({
    key: 'selectedMail',
    default: null,
  }),
  modalVisibile: atom({
    key: 'mailModalVisible',
    default: false,
  }),
};

export const useMailsValue = () => useRecoilValue(mailStates.mailItems);
export const useSetMail = () => useSetRecoilState(mailStates.mailItems);

export const useSetModalVisible = () => useSetRecoilState(mailStates.modalVisibile);
export const useModalVisible = () => useRecoilState(mailStates.modalVisibile);

export const useSetSelectedMail = () => useSetRecoilState(mailStates.selectedMail);
export const useSelectedMail = () => useRecoilState(mailStates.selectedMail);