import React from 'react';
import { MAIL_APP_PRIMARY_COLOR, MAIL_APP_TEXT_COLOR } from '../app.theme';
import { Typography, Box } from '@mui/material';

const Header = () => {
  return (
    <Box
      px={2}
      pt={2}
      sx={{ width: '100%', textAlign: 'left', backgroundColor: MAIL_APP_PRIMARY_COLOR }}
    >
      <Typography sx={{ color: MAIL_APP_TEXT_COLOR }} paragraph variant={'h5'}>
        Mail
      </Typography>
    </Box>
  );
};

export default Header;
