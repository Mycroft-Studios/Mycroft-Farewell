import React, { useEffect, useState } from 'react';
import { NuiProvider } from 'react-fivem-hooks';
import { useHistory } from 'react-router-dom';
import styled from 'styled-components';
import { Header } from './styles/header.styles';
import { IPhoneSettings } from '@project-error/npwd-types';
import { i18n } from 'i18next';
import { IconButton, Theme, StyledEngineProvider, ThemeProvider, Typography } from '@mui/material';
import { ArrowBack } from '@mui/icons-material';
import { GarageItem } from './types/garage';
import { MockGarage } from './utils/constants';
import { VehicleList } from './components/VehicleList';
import fetchNui from './utils/fetchNui';
import { ServerPromiseResp } from './types/common';

const Container = styled.div<{ isDarkMode: any }>`
  flex: 1;
  padding: 1.5rem;
  display: flex;
  box-sizing: border-box;
  flex-direction: column;
  overflow: auto;
  max-height: 100%;
  background-color: #fafafa;
  ${({ isDarkMode }) =>
    isDarkMode &&
    `
    background-color: #212121;
  `}
`;
interface AppProps {
  theme: Theme;
  i18n: i18n;
  settings: IPhoneSettings;
}

const App = (props: AppProps) => {
  const history = useHistory();
  const [vehicles, setVehicles] = useState<GarageItem[] | undefined>([]);
  const [mappedVeh, setMappedVeh] = useState<any>(null);

  const isDarkMode = props.theme.palette.mode === 'dark';

  useEffect(() => {
    fetchNui<ServerPromiseResp<GarageItem[]>>('npwd:qb-garage:getVehicles').then((resp) => {
      setVehicles(resp.data);
    });
  }, []);


  useEffect(() => {
    if (vehicles) {
      const mappedVehicles = vehicles?.reduce((vehs: any, vehicle: any) => {
        if (!vehs[vehicle.type]) vehs[vehicle.type] = [];
        vehs[vehicle.type].push(vehicle);
        return vehs;
      }, {});

      setMappedVeh(mappedVehicles);
    }
  }, [vehicles]);

  return (
    <StyledEngineProvider injectFirst>
      <ThemeProvider theme={props.theme}>
        <Container isDarkMode={isDarkMode}>
          <Header>
            <IconButton color="primary" onClick={() => history.goBack()}>
              <ArrowBack />
            </IconButton>
            <Typography fontSize={24} color="primary" fontWeight="bold">
              Garage
            </Typography>
          </Header>
          {mappedVeh && <VehicleList isDarkMode={isDarkMode} vehicles={mappedVeh} />}
        </Container>
      </ThemeProvider>
    </StyledEngineProvider>
  );
};

const WithProviders: React.FC<AppProps> = (props) => (
  <NuiProvider>
    <App {...props} />
  </NuiProvider>
);

export default WithProviders;
