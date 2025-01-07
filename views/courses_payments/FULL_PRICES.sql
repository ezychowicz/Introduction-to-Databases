--widok pelnych cen za dane serwisy - nie dla studentow tylko dla zwyklych userow

create view FULL_PRICE as
select T1.ServiceID, T1.FullPrice
	from 
		(select ServiceID, PriceOthers as FullPrice from ClassMeetingService 
		union
		select ServiceID, EntryFee as FullPrice from StudiesService 
		union
		select ServiceID, Price as FullPrice from ConventionService 
		union
		select ServiceID, FullPrice from CourseService
		union 
		select ServiceID, Price from WebinarService
		) as T1



