// Copyright (c) The Dijets Core Contributors
// SPDX-License-Identifier: Apache-2.0

use anyhow::Result;
use dijets_events_fetcher::DijetsEventsFetcher;
use dijets_types::account_address::AccountAddress;
use structopt::StructOpt;

#[derive(Debug, StructOpt)]
struct Opt {
    /// Full URL address to connect to - should include port number, if applicable
    #[structopt(short = "u", long)]
    url: String,
    #[structopt(subcommand)] // Note that we mark a field as a subcommand
    cmd: Command,
}

#[derive(Debug, StructOpt)]
enum Command {
    #[structopt(name = "get-payment-events")]
    GetPaymentEvents { accounts: Vec<AccountAddress> },
}

#[tokio::main]
async fn main() -> Result<()> {
    let opt = Opt::from_args();
    let events_fetcher = DijetsEventsFetcher::new(opt.url.as_str())?;
    match opt.cmd {
        Command::GetPaymentEvents { accounts } => {
            for acc in accounts {
                if let Some((sent_handle, received_handle)) =
                    events_fetcher.get_payment_event_handles(acc).await?
                {
                    for evt in events_fetcher.get_all_events(&sent_handle).await? {
                        println!("{:?}", evt);
                    }
                    for evt in events_fetcher.get_all_events(&received_handle).await? {
                        println!("{:?}", evt);
                    }
                };
            }
        }
    }
    Ok(())
}
