import {
  Box,
  ListItem,
  List,
  ListSubheader,
  Collapse,
  Accordion,
  AccordionSummary,
  Typography,
  AccordionDetails,
  Stack,
} from '@mui/material';
import { green, grey, orange, red } from '@mui/material/colors';
import React, { useState } from 'react';
import { GarageItem } from '../types/garage';
import FlightIcon from '@mui/icons-material/Flight';
import PedalBikeIcon from '@mui/icons-material/PedalBike';
import DirectionsCarIcon from '@mui/icons-material/DirectionsCar';
import DirectionsBoatIcon from '@mui/icons-material/DirectionsBoat';
import VehicleDetails from './VehicleDetails';

interface VehicleListProps {
  isDarkMode: boolean;
  vehicles: any;
}

export const VehicleList: React.FC<VehicleListProps> = ({ vehicles, isDarkMode }) => {
  const [collapseId, setCollapseId] = useState<string | null>('car');
  const typeIcon = {
    car: {
      icon: <DirectionsCarIcon sx={{ fontSize: 35 }} />,
      status: {
        out: orange[500],
        garaged: green[500],
        impounded: red[500],
        seized: red[500],
        unknown: grey[500],
      },
    },
    aircraft: {
      icon: <FlightIcon sx={{ fontSize: 35 }} />,
      status: {
        out: orange[500],
        garaged: green[500],
        impounded: red[500],
        seized: red[500],
        unknown: grey[500],
      },
    },
    boat: {
      icon: <DirectionsBoatIcon sx={{ fontSize: 35 }} />,
      status: {
        out: orange[500],
        garaged: green[500],
        impounded: red[500],
        seized: red[500],
        unknown: grey[500],
      },
    },
    bike: {
      icon: <PedalBikeIcon sx={{ fontSize: 35 }} />,
      status: {
        out: orange[500],
        garaged: green[500],
        impounded: red[500],
        seized: red[500],
        unknown: grey[500],
      },
    },
  };

  const expandItem = (id: string) => {
    setCollapseId(id);
  };

  return (
    <Box>
      {Object.keys(vehicles).map((key) => (
        <List
          subheader={
            <ListSubheader sx={{ cursor: 'pointer', position: "static" }} onClick={() => expandItem(key)}>
              {key.toUpperCase()}
            </ListSubheader>
          }
        >
          <Collapse in={collapseId === key}>
            {vehicles[key].map((veh: GarageItem) => {
              return (
                <ListItem>
                  <Accordion
                    sx={{
                      width: '100%',
                      borderBottom: '4px solid',
                      borderBottomColor: typeIcon[veh.type].status[veh.state],
                    }}
                  >
                    <AccordionSummary>
                      <Box
                        sx={{
                          display: 'flex',
                          justifyContent: 'space-between',
                          width: '100%',
                          alignItems: 'center',
                        }}
                      >
                        <Box sx={{ display: 'flex', gap: 3, alignItems: 'center' }}>
                          {typeIcon[veh.type].icon}
                          <Stack spacing={1}>
                            <Typography sx={{ fontSize: 15 }}>
                              {veh.brand + ' ' + veh.vehicle}
                            </Typography>
                            <Typography sx={{ fontSize: 15 }}>{veh.plate}</Typography>
                          </Stack>
                        </Box>
                        <Typography sx={{ fontSize: 14 }}>{veh.state.toUpperCase()}</Typography>
                      </Box>
                    </AccordionSummary>
                    <AccordionDetails
                      sx={{
                        display: 'flex',
                        justifyContent: 'center',
                        alignItems: 'center',
                        flexDirection: 'column',
                      }}
                    >
                      <VehicleDetails veh={veh} />
                    </AccordionDetails>
                  </Accordion>
                </ListItem>
              );
            })}
          </Collapse>
        </List>
      ))}
    </Box>
  );
};
