import SearchIcon from "@mui/icons-material/Search";
import { Box } from "@mui/material";
import { IconTextField } from "components/shared";
import { HbToggleButtonGroup } from "components/shared/HbToggleButtonGroup";
import { LOCALE } from "locales";
import PropTypes from "prop-types";
import { useIntl } from "react-intl";
import { filterOptions } from "./constants";
import { useCallback, useState } from "react";
import { debounce } from "lodash";

export const UserInvestmentsFilters = ({ marginBottom, disabled, SearchQuery, setSearchQuery, filter, setFilter }) => {
  const intl = useIntl();
  const [searchTerm, setSearchTerm] = useState(SearchQuery);

  const onFilterChange = (e) => {
    setFilter(e.value);
  };

  const search = useCallback(
    debounce((searchTerm) => {
      setSearchQuery(searchTerm);
    }, 1000),
    []
  );

  const onSearchChange = (e) => {
    setSearchTerm(e);
    search(e);
  };

  return (
    <Box sx={{ display: "flex", justifyContent: "space-between", marginBottom: marginBottom || "0px" }}>
      <IconTextField
        InputLabelProps={{ shrink: true }}
        placeholder={intl.formatMessage({ id: LOCALE.transactions.search })}
        value={searchTerm}
        setter={onSearchChange}
        width="28.75rem"
        iconComponent={<SearchIcon />}
        disabled={disabled}
      />
      <Box sx={{ display: "flex", gap: "1.5rem", alignSelf: "center" }}>
        <HbToggleButtonGroup
          defaultValue={filter}
          items={filterOptions}
          onSelectionChange={onFilterChange}
          disabled={disabled}
          filter={filter}
          sxButtons={{
            color: "#212121",
            height: "2.5rem",
            width: "7.1rem",
            fontWeight: "bold",
          }}
        />
      </Box>
    </Box>
  );
};

UserInvestmentsFilters.propsTypes = {
  marginBottom: PropTypes.string,
  disabled: PropTypes.bool,
  SearchQuery: PropTypes.string,
  setSearchQuery: PropTypes.func,
  filter: PropTypes.string,
  setFilter: PropTypes.func,
};

UserInvestmentsFilters.defaultProps = {
  marginBottom: "",
  disabled: false,
  SearchQuery: "",
  setSearchQuery: () => {},
  filter: "",
  setFilter: () => {},
};
