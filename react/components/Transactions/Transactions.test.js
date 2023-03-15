import { MockedProvider } from "@apollo/client/testing";
import { render, screen } from "@testing-library/react";
import { GET_MONEY_TRANSFERS_GQL } from "graphql/queries";
import { IntlProvider } from "locales";
import { mockViewports } from "testHelpers";
import { MOCK_TRANSFER_DATA } from "testHelpers/mockData";
import { Transactions } from "./Transactions";

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
          content: MOCK_TRANSFER_DATA,
        },
      },
    },
  },
];

beforeEach(() => {
  mockViewports();
  mockComponent();
});

const mockComponent = () => {
  render(
    <IntlProvider locale="en">
      <MockedProvider mocks={mocks} addTypename={false}>
        <Transactions />
      </MockedProvider>
    </IntlProvider>
  );
};

describe("Transactions page tests", () => {
  it("should check first row data for date column from mocked data", async () => {
    expect(await screen.findByText("Feb 10, 2023", {})).toBeInTheDocument();
  });
});
