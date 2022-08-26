---Cleaning Data in Sql ---


--- View what the table has
select * 
from Portfolio_Project.dbo.NashvilleHousing

--- Change Date Format 
select saledate, convert(date,saledate)
from Portfolio_Project.dbo.NashvilleHousing

update NashvilleHousing 
set SaleDate= convert(date,saledate)


alter table NashvilleHousing
add Sale_date_converted date;

update NashvilleHousing 
set Sale_date_converted= convert(date,saledate)


---Populate Property Address data

select *
from Portfolio_Project.dbo.NashvilleHousing
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull (a.propertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing as a
join  Portfolio_Project.dbo.NashvilleHousing as b
on a.parcelid= b.parcelid
and a.uniqueid <> b.uniqueid
where a.PropertyAddress is null


update a
set PropertyAddress = isnull (a.propertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing as a
join  Portfolio_Project.dbo.NashvilleHousing as b
on a.parcelid= b.parcelid
and a.uniqueid <> b.uniqueid
where a.PropertyAddress is null


--- Breaking Out Address into individual Columns (Address, City, State)

select propertyaddress
from Portfolio_Project.dbo.NashvilleHousing

select 
SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) as Address,
SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress) + 1,len(PropertyAddress)) as Address
from Portfolio_Project.dbo.NashvilleHousing


alter table NashvilleHousing
add Property_split_address nvarchar(255);

update NashvilleHousing 
set Property_split_address= SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress)-1) 

alter table NashvilleHousing
add Property_split_city nvarchar(255);

update NashvilleHousing 
set Property_split_city= SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress) + 1,len(PropertyAddress))

select *
from Portfolio_Project.dbo.NashvilleHousing


--- Breaking Owner Address into Address, City and State
select OwnerAddress
from Portfolio_Project.dbo.NashvilleHousing

select 
PARSENAME(Replace(OwnerAddress,',','.') ,3),
PARSENAME(Replace(OwnerAddress,',','.') ,2),
PARSENAME(Replace(OwnerAddress,',','.') ,1)
from Portfolio_Project.dbo.NashvilleHousing

alter table NashvilleHousing
add Owner_split_address nvarchar(255);

update NashvilleHousing 
set Owner_split_address= PARSENAME(Replace(OwnerAddress,',','.') ,3)

alter table NashvilleHousing
add Owner_split_city nvarchar(255);

update NashvilleHousing 
set Owner_split_city= PARSENAME(Replace(OwnerAddress,',','.') ,2)

alter table NashvilleHousing
add Owner_split_state nvarchar(255);

update NashvilleHousing 
set Owner_split_state= PARSENAME(Replace(OwnerAddress,',','.') ,1)


select *
from Portfolio_Project.dbo.NashvilleHousing



--- Change Y and N to Yes and No in "sold as vacant" field

select distinct(SoldAsVacant), count(soldasvacant)
from Portfolio_Project.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant= 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from Portfolio_Project.dbo.NashvilleHousing

update NashvilleHousing 
set SoldAsVacant = case when SoldAsVacant= 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end


--- Remove Duplicates
with Row_num_CTE as(
select *, 
ROW_NUMBER() over (
partition by ParcelId,PropertyAddress,SalePrice,SaleDate,LegalReference
 order by UniqueID) row_num
from Portfolio_Project.dbo.NashvilleHousing 
)

select *
from Row_num_CTE
where row_num > 1


--- Delete Unusual Columns


select *
from Portfolio_Project.dbo.NashvilleHousing

Alter table Portfolio_Project.dbo.NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate
