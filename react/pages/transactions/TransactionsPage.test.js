import { MockedProvider } from "@apollo/client/testing";
import { render, screen } from "@testing-library/react";
import { GET_MONEY_TRANSFERS_GQL } from "graphql/queries";
import { IntlProvider } from "locales";
import { TransactionsPage } from "./TransactionsPage";

const mocks = [
  {
    request: {
      query: GET_MONEY_TRANSFERS_GQL,
      variables: {
        pageNo: 0,
        pageSize: 100,
      },
    },
    result: {
      data: {
        moneyTransfers: {
          content: [],
        },
      },
    },
  },
];

describe("TransactionsPage page tests", () => {
  it("should check all button", async () => {
    render(
      <IntlProvider locale="en">
        <MockedProvider mocks={mocks} addTypename={false}>
          <TransactionsPage />
        </MockedProvider>
      </IntlProvider>
    );
    expect(await screen.findByText("All", {})).toBeInTheDocument();
  });
});
