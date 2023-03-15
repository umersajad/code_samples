import { Box, styled, TableCell, TableRow } from "@mui/material";
import HbLoader from "components/HbLoader/HbLoader";
import { HbTable } from "components/shared/HbTable";
import { LOCALE } from "locales";
import _ from "lodash";
import moment from "moment";
import { useEffect, useState } from "react";
import { useIntl } from "react-intl";
import { HEADER_ITEMS, TRANSACTIONS_STATES } from "./constants";
import { InvestmentAsset } from "./InvestmentAsset";
import { UserInvestmentsFilters } from "./UserInvestmentsFilters";
import { useMoneyTransfersQuery } from "graphql/hooks/useMoneyTransfersQuery";

const Container = styled(Box)({
  paddingLeft: "1.5rem",
  paddingRight: "1.5rem",
  marginTop: "1.6875rem",
  marginBottom: "6rem",
  color: "black",
});

const CustomTableCell = styled(TableCell, {
  shouldForwardProps: (props) => props.includes("fontFamily", "width"),
})(({ theme, fontFamily, width }) => ({
  fontFamily: fontFamily || "THICCCBOI-Medium",
  color: "#282320",
  width: width || "20%",
  [theme.breakpoints.up("lg")]: {
    fontSize: "1rem",
  },
  [theme.breakpoints.down("lg")]: {
    fontSize: "0.9rem",
  },
}));

const CustomTableRow = styled(TableRow)(({ index }) => ({
  backgroundColor: index % 2 === 0 ? "transparent" : "#F5F3F1",
}));

function searchFromData(data, searchQuery) {
  return _.filter(data, (obj) => {
    const typeMatch = obj?.type?.toLowerCase()?.includes(searchQuery.toLowerCase());
    const memoMatch = obj?.memo?.toLowerCase()?.includes(searchQuery.toLowerCase());
    const dateMatch = moment(new Date(obj?.date)).format("MMM D, Y").toLowerCase()?.includes(searchQuery.toLowerCase());
    const nameMatch = obj?.asset?.name?.toLowerCase()?.includes(searchQuery);
    const cityMatch = obj?.asset?.address?.city?.toLowerCase()?.includes(searchQuery);
    const stateMatch = obj?.asset?.address?.state?.toLowerCase()?.includes(searchQuery);
    const amountMatch = String(obj?.amount).includes(searchQuery);
    return typeMatch || amountMatch || memoMatch || dateMatch || nameMatch || cityMatch || stateMatch;
  });
}

function sortDescData(data) {
  return _.reverse(
    _.sortBy(data, function (t) {
      return new Date(t.date);
    })
  );
}

export const Transactions = () => {
  const itemsPerPage = 10;
  const [selectedPage, setSelectedPage] = useState(0);
  const [searchQuery, setSearchQuery] = useState("");
  const [filterItem, setFilterItem] = useState(TRANSACTIONS_STATES.all);
  const [transactions, setTransactions] = useState(null);
  const [transfersLength, setTransfersLength] = useState(0);
  const intl = useIntl();

  const { transfers: userTransfers } = useMoneyTransfersQuery({
    pageNo: 0,
    pageSize: 100,
  });

  function filterData(data, filter) {
    if (filterItem === TRANSACTIONS_STATES.all) {
      return data;
    } else {
      return _.filter(data, (obj) => {
        const typeMatch = obj?.type?.toLowerCase()?.includes(filter.toLowerCase());
        return typeMatch;
      });
    }
  }

  useEffect(() => {
    if (searchQuery.length > 0) {
      setFilterItem(TRANSACTIONS_STATES.all);
    }
  }, [searchQuery]);

  useEffect(() => {
    if (userTransfers) {
      const searchedResults = searchFromData(userTransfers, searchQuery);
      const sortedTransactionsDesc = sortDescData(searchedResults);
      const result = filterData(sortedTransactionsDesc, filterItem);
      const chunks = _.chunk(result, itemsPerPage);
      setTransactions(chunks[selectedPage]);
      setTransfersLength(result.length);
    }
  }, [filterItem, searchQuery, selectedPage, userTransfers]);

  useEffect(() => {
    if (!userTransfers) {
      return <HbLoader />;
    }
  }, [userTransfers]);

  function formattedAmount(amount) {
    return intl.formatNumber(amount, {
      style: "currency",
      currency: "USD",
      maximumFractionDigits: 0,
      currencySign: "accounting",
    });
  }

  const formattedUserTransfers = _.map(transactions, function transaction(tx, index) {
    function isContributionTx() {
      return TRANSACTIONS_STATES.contribution === tx.type;
    }
    return {
      id: "key-" + index,
      investment: <InvestmentAsset asset={tx.asset} />,
      date: moment(new Date(tx.date)).format("MMM D, Y"),
      type: _.capitalize(tx.type),
      distributionMemo: tx.memo,
      amount: formattedAmount(isContributionTx() ? -tx.amount : tx.amount),
    };
  });
  return (
    <Container>
      <UserInvestmentsFilters
        searchQuery={searchQuery}
        setSearchQuery={setSearchQuery}
        filter={filterItem}
        setFilter={setFilterItem}
        disabled={userTransfers?.length === 0}
        marginBottom="1.5rem"
      />
      <HbTable
        headerItems={HEADER_ITEMS}
        rowsPerPage={itemsPerPage}
        itemsLength={transfersLength}
        showNoDataButton={false}
        emptyText={intl.formatMessage({ id: LOCALE.transactions.noTransactions })}
        page={selectedPage}
        handlePageChange={(e) => setSelectedPage(e)}
        firstHeaderPadding="2rem"
        lastHeaderPadding="3rem"
      >
        {formattedUserTransfers.map((item, index) => {
          return (
            <CustomTableRow index={index} key={item.id}>
              <CustomTableCell width="15%" sx={{ paddingLeft: "2rem" }}>
                {item.date}
              </CustomTableCell>
              <CustomTableCell>{item.investment}</CustomTableCell>
              <CustomTableCell width="15%">{item.type}</CustomTableCell>
              <CustomTableCell width="35%">{item.distributionMemo}</CustomTableCell>
              <CustomTableCell sx={{ paddingRight: "3rem" }} align="right" fontFamily="THICCCBOI-BOLD">
                {item.amount}
              </CustomTableCell>
            </CustomTableRow>
          );
        })}
      </HbTable>
    </Container>
  );
};
