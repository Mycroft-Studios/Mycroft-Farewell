import React from 'react';
import { Snackbar } from '@mui/material';
import { useSnackbar } from './useSnackbar';
import Alert from './Alert';

export const PhoneSnackbar: React.FC = () => {
  const { alert, isOpen, handleClose } = useSnackbar();

  return (
    <Snackbar
      autoHideDuration={alert?.duration ?? 3000}
      open={isOpen}
      sx={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        height: 'auto',
        position: 'absolute',
        bottom: 75,
        left: '0 !important',
        right: '0 !important',
      }}
      onClose={handleClose}
    >
      <Alert severity={alert?.type || 'info'} onClose={handleClose}>
        {alert?.message || ''}
      </Alert>
    </Snackbar>
  );
};
