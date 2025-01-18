create view FINANCIAL_REPORT as
select s.ServiceType as 'Service Type' , sum(p.PaymentValue) as 'Income'
	from Payments as p
	INNER JOIN OrderDetails as od
	on od.OrderID = p.OrderID AND od.ServiceID = p.ServiceID
	INNER JOIN Services as s
	on s.ServiceID = p.ServiceID
	where p.PaymentDate IS NOT NULL
	group by s.ServiceType


