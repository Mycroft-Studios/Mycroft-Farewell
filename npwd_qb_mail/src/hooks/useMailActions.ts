import { useSetMail } from '../atoms/mail-atoms'
import { useCallback } from 'react';
import { Mail } from '../types/mail';

interface UseMailActionsValue {
  updateReadState: (id: number) => void;
  deleteLocalMail: (id: number) => void;
  updateLocalButton: (id: number) => void;
  newMail: (mail: Mail) => void;
}

export const useMailActions = (): UseMailActionsValue => {
  const setMail = useSetMail();

  const updateReadState = useCallback(
    (id) => {
      setMail((curMail) => {
        const newMail = curMail.map((mail) => {
            if (mail.mailid === id) {
                return { ...mail, read: 1 };
            }
            return mail;
            }
        );
        return newMail;
      });
    },
    [setMail],
  )

  const newMail = useCallback(
    (mail: Mail) => {
      setMail((curMail) => {
        const newMail = [mail, ...curMail];
        return newMail;
      });
    },
    [setMail],
  );

  const updateLocalButton = useCallback(
    (id) => {
      setMail((curMail) => {
        const targetIndex = curMail.findIndex((storedMail) => storedMail.mailid === id);
        const newMailArray = [...curMail];
        newMailArray[targetIndex].button = null;
        return newMailArray;
      });
    },
    [setMail],
  );

  const deleteLocalMail = useCallback(
    (id) => {
      setMail((curMail) => [...curMail].filter((mail) => mail.mailid !== id));
    },
    [setMail],
  );

  return { updateReadState, deleteLocalMail, updateLocalButton, newMail };
};
