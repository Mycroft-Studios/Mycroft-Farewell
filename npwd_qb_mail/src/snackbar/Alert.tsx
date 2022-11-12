import React, { forwardRef } from 'react';
import MuiAlert, { AlertProps } from '@mui/material/Alert';
import { Typography } from '@mui/material';

export const Alert: React.FC<AlertProps> = forwardRef((props, ref) => {
  return (
    <MuiAlert
      sx={{
        zIndex: 10000,
      }}
      elevation={4}
      variant="filled"
      {...props}
      ref={ref}
    >
      <Typography
        sx={{
          maxWidth: '300px',
          wordWrap: 'break-word',
          fontSize: '1.1em',
        }}
      >
        {props.children}
      </Typography>
    </MuiAlert>
  );
});

export default Alert;
