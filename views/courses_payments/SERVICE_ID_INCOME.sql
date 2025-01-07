
create view SERVICE_ID_INCOME as 
select p.ServiceID, sum(p.PaymentValue) as 'Income'
	from Payments as p
	INNER JOIN OrderDetails as od
	on od.OrderID = p.OrderID AND od.ServiceID = p.ServiceID
	INNER JOIN Services as s
	on s.ServiceID = od.ServiceID
	group by p.ServiceID
	