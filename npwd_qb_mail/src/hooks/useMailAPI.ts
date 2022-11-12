import { useCallback } from 'react';
import { useSnackbar } from '../snackbar/useSnackbar';
import { useMailActions } from './useMailActions';
import { ServerPromiseResp } from '../types/common';
import fetchNui from '../utils/fetchNui';
import { buttonContentInt } from '../types/mail';

interface updateMailButtonParams {
  mailid: number;
  button: buttonContentInt;
}

interface MailAPIValue {
  updateRead: (mailid: number) => Promise<void>;
  deleteMail: (mailid: number) => Promise<void>;
  updateMailButton: (data: updateMailButtonParams) => Promise<void>;
}

export const useMailAPI = (): MailAPIValue => {
  const { addAlert } = useSnackbar();
  const { updateReadState, deleteLocalMail, updateLocalButton } = useMailActions();

  const updateRead = useCallback(
    async (mailid: number) => {
      await fetchNui<ServerPromiseResp>("npwd:qb-mail:updateRead", mailid);
      updateReadState(mailid);
    },
    [updateReadState],
  );

  const deleteMail = useCallback(
    async (mailid: number) => {
      const resp = await fetchNui<ServerPromiseResp>("npwd:qb-mail:deleteMail", mailid);

      if (resp.status !== 'ok') {
        return addAlert({
          message: 'Failed to delete mail',
          type: 'error',
        });
      }

      deleteLocalMail(mailid);

      addAlert({
        message: 'Successfully deleted mail',
        type: 'success',
      });
    },
    [addAlert, deleteLocalMail],
  );

  const updateMailButton = useCallback(
    async ({ mailid, button }: updateMailButtonParams) => {
      const resp = await fetchNui<ServerPromiseResp>("npwd:qb-mail:updateButton", {
        mailid,
        button,
      });
      if (resp.status !== 'ok') {
        return addAlert({
          message: 'Failed to accept mail',
          type: 'error',
        });
      }
      updateLocalButton(mailid);

      addAlert({
        message: 'Successfully accepted mail',
        type: 'success',
      });
    },
    [addAlert, updateLocalButton],
  );


  return { updateRead, deleteMail, updateMailButton };
};
