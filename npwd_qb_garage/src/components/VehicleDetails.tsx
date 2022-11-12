import React from 'react';
import { GarageItem } from '../types/garage';
import {
  Button,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  Tooltip,
  Typography,
} from '@mui/material';
import DirectionsCarIcon from '@mui/icons-material/DirectionsCar';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import LocalGasStationIcon from '@mui/icons-material/LocalGasStation';
import BuildIcon from '@mui/icons-material/Build';
import { ServerPromiseResp } from '../types/common';
import fetchNui from '../utils/fetchNui';

const VehicleDetails = ({ veh }: { veh: GarageItem }) => {

  const handleTrackVehicle = (plate: string) => {
    fetchNui<ServerPromiseResp>('npwd:qb-garage:requestWaypoint', { plate }).then((res) => {
      console.log(res.data);
    });
  };

  return (
    <><>
      <List sx={{ width: '70%' }}>
        <ListItem disablePadding sx={{ borderBottom: '1px solid white', mb: '8px' }}>
          <ListItemIcon sx={{ ml: '5px', mr: '20px', minWidth: '25px' }}>
            <Tooltip title="Location">
              <LocationOnIcon />
            </Tooltip>
          </ListItemIcon>
          <ListItemText primary={veh.garage} />
        </ListItem>

       if {veh.stored != false }(
        <ListItem disablePadding sx={{ borderBottom: '1px solid white', mb: '8px' }}>
          <ListItemIcon sx={{ ml: '5px', mr: '20px', minWidth: '25px' }}>
            <Tooltip title="Engine">
              <BuildIcon />
            </Tooltip>
          </ListItemIcon>
       )
          <ListItemText primary={<Typography>{Math.ceil(veh.engine / 10)}%</Typography>} />
        </ListItem><ListItem disablePadding sx={{ borderBottom: '1px solid white', mb: '8px' }}>
          <ListItemIcon sx={{ ml: '5px', mr: '20px', minWidth: '25px' }}>
            <Tooltip title="Fuel">
              <LocalGasStationIcon />
            </Tooltip>
          </ListItemIcon>
          <ListItemText primary={<Typography>{Math.ceil(veh.fuel)}%</Typography>} />
        </ListItem><ListItem disablePadding sx={{ borderBottom: '1px solid white', mb: '8px' }}>
          <ListItemIcon sx={{ ml: '5px', mr: '20px', minWidth: '25px' }}>
            <Tooltip title="Body">
              <DirectionsCarIcon />
            </Tooltip>
          </ListItemIcon>
          <ListItemText primary={<Typography>{Math.ceil(veh.body / 10)}%</Typography>} />
        </ListItem></>
    </><Button color="primary" variant="contained" disabled={veh.state !== 'out'} onClick={() => handleTrackVehicle(veh.plate)}>
        Track
      </Button></>
    </>
  );
};

export default VehicleDetails;