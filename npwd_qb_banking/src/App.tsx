import React, { useState, useEffect } from 'react';
import { NuiProvider, useNuiEvent } from 'react-fivem-hooks';
import { NavLink, Route, useLocation } from 'react-router-dom';
import styled from 'styled-components';

import { IPhoneSettings } from '@project-error/npwd-types';
import { i18n } from 'i18next';
import {
  Theme,
  StyledEngineProvider,
  Paper,
  BottomNavigation,
  BottomNavigationAction,
} from '@mui/material';
import ThemeSwitchProvider from './ThemeSwitchProvider';
import { Receipt, AccountBalanceWallet } from '@mui/icons-material';
import Header, { HEADER_HEIGHT } from './components/Header';
import { path } from '../npwd.config';
import Account from './views/Account';
import Billing from './views/Billing';
import { RecoilRoot } from 'recoil';
import { useSetBankBalance } from './atoms/bank-atoms';
import { PhoneSnackbar } from './snackbar/PhoneSnackbar';
import SnackbarProvider from './snackbar/SnackbarProvider';

const Container = styled(Paper)`
  flex: 1;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  max-height: 100%;
`;

const Content = styled.div`
  flex: 1;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  max-height: calc(100% - 3.5rem - ${HEADER_HEIGHT});
  overflow: auto;
`;

interface AppProps {
  theme: Theme;
  i18n: i18n;
  settings: IPhoneSettings;
}

const App = (props: AppProps) => {
  const { pathname } = useLocation();
  const [page, setPage] = useState(pathname);
  const updateBalance = useSetBankBalance();

  const { data } = useNuiEvent<number>({ event: 'npwd:qb-banking:updateMoney' });

  useEffect(() => {
    if (data) {
      updateBalance(data);
    }
  }, [data]);

  const handleChange = (_e: any, newPage: any) => {
    setPage(newPage);
  };

  return (
    <SnackbarProvider>
      <StyledEngineProvider injectFirst>
        <ThemeSwitchProvider mode={props.theme.palette.mode}>
          <PhoneSnackbar />
          <Container square elevation={0}>
            <Header>Banking</Header>
            <Content>
              <Route exact path={path}>
                <Account />
              </Route>
              <Route path={`${path}/billing`}>
                <Billing />
              </Route>
            </Content>

            <BottomNavigation value={page} onChange={handleChange} showLabels>
              <BottomNavigationAction
                label={'Banking'}
                value={path}
                component={NavLink}
                icon={<AccountBalanceWallet />}
                to={path}
              />
              <BottomNavigationAction
                label={'Billing'}
                value={`${path}/billing`}
                color="secondary"
                component={NavLink}
                icon={<Receipt />}
                to={`${path}/billing`}
              />
            </BottomNavigation>
          </Container>
        </ThemeSwitchProvider>
      </StyledEngineProvider>
    </SnackbarProvider>
  );
};

const WithProviders: React.FC<AppProps> = (props) => (
  <RecoilRoot>
    <NuiProvider>
      <App {...props} />
    </NuiProvider>
  </RecoilRoot>
);

export default WithProviders;
