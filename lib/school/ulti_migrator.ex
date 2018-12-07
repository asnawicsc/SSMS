defmodule School.UltiMigrator do
  use Task
  require IEx
  import Ecto.Query
  alias School.Repo
  alias School.Affairs.{Teacher, Parent, Student}

  def export_to_csv_demo_teacher(conn, params) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"Teacher Demo Data.csv\""
    )
    |> send_resp(200, csv_demo_teacher(conn, params))
  end

  defp csv_demo_teacher(conn, params) do
    all =
      if branch_id != "0" do
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.is_void == 0 and s.branchid == ^params["branch"] and s.salesdate >= ^start_d and
                s.salesdate <= ^end_d and s.brand_id == ^brand_id and b.brand_id == ^brand_id and
                sp.brand_id == ^brand_id,
            group_by: [s.salesdate, b.branchname],
            select: %{
              id: count(s.salesid),
              salesdate: s.salesdate,
              pax: sum(s.pax),
              branchname: b.branchname,
              grand_total: sum(sp.grand_total),
              service_charge: sum(sp.service_charge),
              gst: sum(sp.gst_charge),
              after_disc: sum(sp.after_disc),
              transaction: count(s.salesid),
              sub_total: sum(sp.sub_total),
              rounding: sum(sp.rounding),
              owner: b.manager
            }
          )
        )
      else
        Repo.all(
          from(
            sp in BoatNoodle.BN.SalesPayment,
            left_join: s in BoatNoodle.BN.Sales,
            on: sp.salesid == s.salesid,
            left_join: b in BoatNoodle.BN.Branch,
            on: b.branchid == s.branchid,
            where:
              s.is_void == 0 and s.salesdate >= ^start_d and s.salesdate <= ^end_d and
                sp.brand_id == ^brand_id and b.brand_id == ^brand_id and s.brand_id == ^brand_id,
            group_by: [s.salesdate, b.branchname],
            select: %{
              id: count(s.salesid),
              salesdate: s.salesdate,
              pax: sum(s.pax),
              branchname: b.branchname,
              grand_total: sum(sp.grand_total),
              service_charge: sum(sp.service_charge),
              gst: sum(sp.gst_charge),
              after_disc: sum(sp.after_disc),
              transaction: count(s.salesid),
              sub_total: sum(sp.sub_total),
              rounding: sum(sp.rounding),
              owner: b.manager
            }
          )
        )
      end

    staffs =
      Repo.all(
        from(
          cd in Staff,
          where: cd.brand_id == ^brand.id,
          select: %{
            staff_id: cd.staff_id,
            staff_name: cd.staff_name
          }
        )
      )

    data =
      for item <- all do
        afterdisc = Decimal.to_float(item.after_disc) |> Float.round(2)
        sub_total = Decimal.to_float(item.sub_total) |> Float.round(2)
        service_charge = Decimal.to_float(item.service_charge) |> Float.round(2)
        gst_charge = Decimal.to_float(item.gst) |> Float.round(2)
        rounding = Decimal.to_float(item.rounding) |> Float.round(2)

        disc_amt =
          Decimal.to_float(item.grand_total) -
            (Decimal.to_float(item.sub_total) + Decimal.to_float(item.service_charge) +
               Decimal.to_float(item.gst) + Decimal.to_float(item.rounding))

        grand_total = Decimal.to_float(item.grand_total) |> Float.round(2)

        dis =
          Decimal.to_float(item.sub_total) + Decimal.to_float(item.service_charge) +
            Decimal.to_float(item.gst) + Decimal.to_float(item.rounding) -
            Decimal.to_float(item.grand_total)

        after_disc = (sub_total - dis + rounding) |> Float.round(2)

        nett_sales = grand_total - service_charge - gst_charge - rounding

        total_sales = nett_sales + service_charge

        beforedisc =
          Decimal.to_float(item.sub_total) + Decimal.to_float(item.service_charge) +
            Decimal.to_float(item.gst) + Decimal.to_float(item.rounding)

        # gst_charge = (sub_total - dis) * 0.06

        csv_content = [
          item.salesdate,
          item.pax,
          item.id,
          sub_total |> :erlang.float_to_binary(decimals: 2),
          after_disc |> :erlang.float_to_binary(decimals: 2),
          disc_amt |> :erlang.float_to_binary(decimals: 2),
          gst_charge |> :erlang.float_to_binary(decimals: 2),
          service_charge |> :erlang.float_to_binary(decimals: 2),
          rounding |> :erlang.float_to_binary(decimals: 2),
          total_sales |> :erlang.float_to_binary(decimals: 2),
          item.branchname,
          manager(item.owner, staffs)
        ]
      end

    csv_content = [
      'Date ',
      'Pax',
      'Total Receipts',
      'Gross Sales',
      'After Discount',
      'Discount Amount',
      'SST',
      'Service Charge',
      'Roundings',
      'Total',
      'Branch Name',
      'Branch Owner'
    ]

    csv_content =
      List.insert_at(data, 0, csv_content)
      |> CSV.encode()
      |> Enum.to_list()
      |> to_string
  end
end
